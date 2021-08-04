// import dependencies
const IBMCloudEnv = require('ibm-cloud-env');
const { NoAuthAuthenticator } = require('ibm-cloud-sdk-core');
const CloudantV1 = require('@ibm-cloud/cloudant/cloudant/v1');

IBMCloudEnv.init('/server/config/mappings.json');

// initialize Cloudant
const cloudant_url = IBMCloudEnv.getString('cloudant_url');

const cloudant = CloudantV1.newInstance({
  authenticator: new NoAuthAuthenticator({}),
});

cloudant.setServiceUrl(cloudant_url);
const dbname = 'mydb';

// create mydb database if it does not already exist
cloudant.putDatabase({ db: dbname})
  .then(data => {
    console.log(dbname + ' database created');
  })
  .catch(error => {
    // ignore if database already exists
    if (error.status === 412) {
      console.log(dbname + ' database already exists');
    } else {
      console.log('Error occurred when creating ' + dbname +
      ' database', error.error);
    }
  });

// get names from database
exports.getNames = (req, res, next) => {
  console.log('In route - getNames');

  return cloudant.postAllDocs({
    db: dbname,
    includeDocs: true,
  })
    .then(allDocuments => {
      let fetchedNames = allDocuments.result;
      let names = [];
      let row = 0;
      fetchedNames.rows.forEach(fetchedName => {
        names[row] = {
          _id: fetchedName.id,
          name: fetchedName.doc.name,
          timestamp: fetchedName.doc.timestamp,
        };
        row = row + 1;
      });
      console.log('Get names successful');
      return res.status(200).json(names);
    })
    .catch(error => {
      console.log('Get names failed');
      return res.status(500).json({
        message: 'Get names failed.',
        error: error,
      });
    });
};

// add name to database
exports.addName = (req, res, next) => {
  console.log('In route - addName');
  let name = {
    name: req.body.name,
    timestamp: req.body.timestamp,
  };

  return cloudant.postDocument({
    db: dbname,
    document: name,
  })
    .then(addedName => {
      console.log('Add name successful');
      return res.status(201).json({
        _id: addedName.id,
        name: addedName.name,
        timestamp: addedName.timestamp,
      });
    })
    .catch(error => {
      console.log('Add name failed');
      return res.status(500).json({
        message: 'Add name failed.',
        error: error,
      });
    });
};
