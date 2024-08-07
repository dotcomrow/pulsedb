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
      accountId: "$4",
      accessKeyId: "$5",
      secretAccessKey: "$6",
  });

  const bucket = r2.bucket("$3");

  async function uploadFile(filename) {

    await bucket.uploadFile(filename, filename, {}, "application/json");
  }

  async function getSchema() {
    var regularFiles = fromDir('./', '.graphql');
    regularFiles = regularFiles.filter( x => !new Set(adminFiles).has(x) );
    
    var combined = "";

    for(let x = 0; x < regularFiles.length; x++) {
      const data = fs.readFileSync(regularFiles[x],{ encoding: 'utf8', flag: 'r' });
      combined += data;
    }
    return buildSchema(combined);
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
    // var schemas = await fetchSchemas();
    
    // const storage = new Storage();
    // const mergedSchema = mergeSchemas({
    //   schemas: schemas
    // })
    // const schema_json = introspectionFromSchema(mergedSchema);

    const regularFileName = 'graphql_schema.json';

    const schema_json = introspectionFromSchema(await getSchema());

    let json = JSON.stringify(schema_json);
    // console.log(json);

    // console.log(admin_json);

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
