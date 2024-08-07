curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node

cat > package.json <<EOF
{
  "name": "schema-builder",
  "version": "1.0.0",
  "dependencies": {
    "serialize-error": "^11.0.3"
  },
  "devDependencies": {
    "webpack": "^5.89.0",
    "webpack-cli": "^5.1.4",
    "babel-loader": "^9.1.3",
    "path-browserify": "^1.0.1",
    "crypto-browserify": "3.12.0",
    "stream-browserify": "^3.0.0",
    "https-browserify": "^1.0.0",
    "os-browserify": "^0.3.0",
    "browserify-zlib": "^0.2.0",
    "util": "^0.12.5",
    "url": "^0.11.3",
    "stream-http": "^3.2.0",
    "assert": "^2.1.0",
    "@google-cloud/bigquery": "^7.3.0",
    "fs": "^0.0.1-security",
    "querystring-es3": "^0.2.1",
    "net-browserify": "^0.2.4",
    "process": "^0.11.10",
    "buffer": "^6.0.3",
    "graphql": "^16.8.1",
    "@graphql-tools/schema": "^9.0.0",
    "node-cloudflare-r2": "0.1.5",
    "npm-gcp-logging": "^1.0.53",
    "npm-gcp-token": "^1.0.12"
  },
  "private": true,
  "type": "module",
  "main": "index.js"
}
EOF

npm install

cat > schema_builder.js <<EOF
import { 
  introspectionFromSchema,
  buildSchema } from "graphql";
import fs from 'fs';
import path from 'path';
import { serializeError } from "serialize-error";
import { R2 } from 'node-cloudflare-r2';
import { GCPLogger } from "npm-gcp-logging";
import { GCPAccessToken } from "npm-gcp-token";
import process from 'node:process';

async function main() {

  var logging_token = await new GCPAccessToken(
    process.env.GCP_LOGGING_CREDENTIALS
  ).getAccessToken("https://www.googleapis.com/auth/logging.write");

  const r2 = new R2({
      accountId: process.env.R2_ACCOUNT_ID,
      accessKeyId: process.env.R2_ACCESS_KEY_ID,
      secretAccessKey: process.env.R2_ACCESS_KEY_SECRET,
  });

  const bucket = r2.bucket(process.env.BUCKET_NAME);

  async function uploadFile(filename) {

    await bucket.uploadFile(filename, filename, {}, "application/json");
  }

  async function getSchema() {
    try {
      var regularFiles = fromDir('./', '.graphql');
      
      var combined = "";

      for(let x = 0; x < regularFiles.length; x++) {
        const data = fs.readFileSync(regularFiles[x],{ encoding: 'utf8', flag: 'r' });
        combined += data;
      }
      await GCPLogger.logEntry(
        process.env.GCP_LOGGING_PROJECT_ID,
        logging_token.access_token,
        process.env.LOG_NAME,
        [
          {
            severity: "INFO",
            // textPayload: message,
            jsonPayload: {
              schema: buildSchema(combined)
            },
          },
        ]
      );
      return buildSchema(combined);
    } catch (err) {
      const responseError = serializeError(err);
      await GCPLogger.logEntry(
        process.env.GCP_LOGGING_PROJECT_ID,
        logging_token.access_token,
        process.env.LOG_NAME,
        [
          {
            severity: "ERROR",
            // textPayload: message,
            jsonPayload: {
              responseError,
            },
          },
        ]
      );
    }
  }

  function fromDir(startPath, filter) {

      // console.log('Starting from dir '+startPath+'/');

      if (!fs.existsSync(startPath)) {
          console.log("no dir ", startPath);
          return;
      }

      var foundList = [];
      var files = fs.readdirSync(startPath);
      for (var i = 0; i < files.length; i++) {
          var filename = path.join(startPath, files[i]);
          var stat = fs.lstatSync(filename);
          if (stat.isDirectory()) {
              fromDir(filename, filter).forEach((item) => {
                foundList.push(item);
              }); //recurse
          } else if (filename.endsWith(filter)) {
              foundList.push(filename);
          };
      };
      return foundList;
  };

  async function query() {
    
    const regularFileName = 'graphql_schema.json';
    try {
        var schema_json = introspectionFromSchema(await getSchema());
    } catch (err) {
      const responseError = serializeError(err);
      await GCPLogger.logEntry(
        process.env.GCP_LOGGING_PROJECT_ID,
        logging_token.access_token,
        process.env.LOG_NAME,
        [
          {
            severity: "ERROR",
            // textPayload: message,
            jsonPayload: {
              responseError,
            },
          },
        ]
      );
      return;
    }

    let json = JSON.stringify(introspectionFromSchema(await getSchema()));

    await fs.writeFile(regularFileName, json,{ flush:true }, (err) => {
      err && console.error(err)
    });
    fs.readFile(regularFileName, 'utf8', async (err, data) => {
      if (err) {
        console.error(err)
        return
      }
      await uploadFile(regularFileName);
    });
  }

  try {
    await GCPLogger.logEntry(
      process.env.GCP_LOGGING_PROJECT_ID,
      logging_token.access_token,
      process.env.LOG_NAME,
      [
        {
          severity: "INFO",
          // textPayload: message,
          jsonPayload: {
            message:"Schema Builder Started"
          },
        },
      ]
    );
    await query();
  } catch (err) {
    const responseError = serializeError(err);
    await GCPLogger.logEntry(
      process.env.GCP_LOGGING_PROJECT_ID,
      logging_token.access_token,
      process.env.LOG_NAME,
      [
        {
          severity: "ERROR",
          // textPayload: message,
          jsonPayload: {
            responseError,
          },
        },
      ]
    );
  }
}
main(...process.argv.slice(2));
EOF

rm -rf *.graphql

cat > User.graphql <<EOF
type User { id: ID! preferences: Preferences! privateKey: PKIKey! publicKey: PKIKey! updatedAt: Int! } extend type Query { user(id: ID!): User! } type Mutation { updateUserPreferences(id: ID!, preferences: Preferences!): User! updateUserPrivateKey(id: ID!, privateKey: PKIKey!): User! updateUserPublicKey(id: ID!, publicKey: PKIKey!): User! createUser(id: ID!, preferences: Preferences!, privateKey: PKIKey!, publicKey: PKIKey!): User! }
EOF
cat > Preferences.graphql <<EOF
type Preferences { darkMode: Boolean! systemSetting: Boolean! }
EOF
cat > PKIKey.graphql <<EOF
type PKIKey { alg: String! e: String! ext: Boolean! key_ops: [String!]! kty: String! n: String! }
EOF
cat > Query.graphql <<EOF
""" The root query type, represents all of the entry points into our object graph. """ type Query { hello: String! }
EOF


node schema_builder.js

cat <<EOF
{
  "res": "test"
}
EOF