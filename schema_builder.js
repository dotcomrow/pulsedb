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
              schema: combined
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
    var schema_txt = await getSchema();
    try {
        introspectionFromSchema(schema_txt);
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

    let json = JSON.stringify(introspectionFromSchema(schema_txt));

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
