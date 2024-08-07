import { 
  introspectionFromSchema,
  buildSchema } from "graphql";
import fs from 'fs';
import path from 'path';
import { serializeError } from "serialize-error";
import { R2 } from 'node-cloudflare-r2';

async function main() {

  const r2 = new R2({
      accountId: "$4",
      accessKeyId: "$5",
      secretAccessKey: "$6",
  });

  const bucket = r2.bucket("$3");

  async function uploadFile(filename) {

    await bucket.uploadFile(filename, filename, {}, "application/json");
  }

  async function getRegularSchema() {
    var regularFiles = fromDir('./', '.graphql');
    var adminFiles = fromDir('./', '.admin.graphql');
    regularFiles = regularFiles.filter( x => !new Set(adminFiles).has(x) );
    
    var combined = "";

    for(let x = 0; x < regularFiles.length; x++) {
      const data = fs.readFileSync(regularFiles[x],{ encoding: 'utf8', flag: 'r' });
      combined += data;
    }
    return buildSchema(combined);
  }

  async function getAdminSchema() {
    var adminFiles = fromDir('./', '.admin.graphql');
    
    var combined = "";

    for(let x = 0; x < adminFiles.length; x++) {
      const data = fs.readFileSync(adminFiles[x],{ encoding: 'utf8', flag: 'r' });
      combined += data;
      if (fs.existsSync(adminFiles[x].replace('.admin.graphql', '.graphql'))) {
        const regData = fs.readFileSync(adminFiles[x].replace('.admin.graphql', '.graphql'),{ encoding: 'utf8', flag: 'r' });
        combined += regData;
      }
    }
    var additionalSchemas = [
      "/Query.graphql",
      "/Setting.graphql",
      "/Weight.graphql",
      "/Cart.graphql",
      "/Date.graphql",
      "/Price.graphql",
      "/DateTime.graphql",
      "/Country.graphql",
      "/Province.graphql",
      "/Status.graphql",
      "/ShippingSetting.graphql",
      "/StoreSetting.graphql",
    ];
    for(let x = 0; x < additionalSchemas.length; x++) {
      var file = fromDir('./', additionalSchemas[x])[0];
      console.log(file)
      const data = fs.readFileSync(file,{ encoding: 'utf8', flag: 'r' });
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
    const adminFileName = 'graphql_admin_schema.json';

    const schema_json = introspectionFromSchema(await getRegularSchema());
    const admin_schema_json = introspectionFromSchema(await getAdminSchema());

    let json = JSON.stringify(schema_json);
    // console.log(json);

    let admin_json = JSON.stringify(admin_schema_json);
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



    await fs.writeFile(adminFileName, admin_json,{ flush:true }, (err) => {
      err && console.error(err)
    });
    fs.readFile(adminFileName, 'utf8', async (err, data) => {
      if (err) {
        console.error(err)
        return
      }
      await uploadFile(adminFileName);
    });
  }

  try {
    await query();
  } catch (err) {
    const responseError = serializeError(err);
    console.error(responseError);
  }
}
main(...process.argv.slice(2));
