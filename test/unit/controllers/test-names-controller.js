const chai = require('chai');
const mockRequire = require('mock-require');
const sinon = require('sinon');
const sinonChai = require('sinon-chai');
const chaiAsPromised = require('chai-as-promised');

const expect = chai.expect;
const sandbox = sinon.createSandbox();
chai.use(sinonChai);
chai.use(chaiAsPromised);


// example golden path export unit tests of names controller
describe('Test golden paths of names controller', () => {
  class cloudantMock {
    static newInstance(options) {
      return new this;
    }

    setServiceUrl(url) {
      return null;
    }

    putDatabase(params) {
      return Promise.reject({
        message: 'file_exists',
        status: 412,
      });
    }

    postDocument(options) {
      return Promise.resolve({
        id: 'id',
        name: 'name',
        timestamp: 'timestamp',
      });
    }

    postAllDocs(params) {
      return Promise.resolve({
        result: {
          rows: [
            {
              id: 1,
              doc: {
                name: 'name',
                timestamp: 'timestamp',
              },
            },
            {
              id: 2,
              doc: {
                name: 'name',
                timestamp: 'timestamp',
              },
            },
          ],
        },
      });
    }
  }

  let namesController;
  let res;
  before(() => {
    mockRequire('@ibm-cloud/cloudant/cloudant/v1', cloudantMock);

    res = mockRequire.reRequire('express/lib/response');
    sandbox.stub(res, 'json');
    sandbox.spy(res, 'status');

    namesController = mockRequire.reRequire(
      '../../../server/controllers/names-controller',
    );
  });

  afterEach(() => {
    sandbox.reset();
  });

  after(() => {
    sandbox.restore();
    mockRequire.stopAll();
  });

  it('should return some names', () => {
    const mockReq = {};

    const resultPromise = namesController.getNames(mockReq, res);
    expect(resultPromise).to.eventually.be.fulfilled
      .then(() => {
        expect(res.status).to.have.been.calledOnceWith(200);
        expect(res.json).to.have.been.calledOnceWith([
          {
            id: 1,
            doc: {
              name: 'name',
              timestamp: 'timestamp',
            },
          },
          {
            id: 2,
            doc: {
              name: 'name',
              timestamp: 'timestamp',
            },
          },
        ]);
      });
  });

  it('should correctly add a name', () => {
    const mockReq = {
      body: {
        name: 'name',
        timestamp: 'timestamp',
      },
    };

    const resultPromise = namesController.addName(mockReq, res);
    expect(resultPromise).to.eventually.be.fulfilled
      .then(() => {
        expect(res.status).to.have.been.calledOnceWith(201);
        expect(res.json).to.have.been.calledOnceWith({
          _id: 'id',
          name: 'name',
          timestamp: 'timestamp',
        });
      });
  });
});


// example unit tests of export failures in names controller
describe('Test failure paths of names controller', () => {
  class cloudantMock {
    static newInstance(options) {
      return new this;
    }

    setServiceUrl(url) {
      return null;
    }

    putDatabase(params) {
      return Promise.reject({
        error: 'another_error',
      });
    }

    postDocument(options) {
      return Promise.reject('There was an error with postDocument.');
    }

    postAllDocs(params) {
      return Promise.reject('There was an error with postAllDocs.');
    }
  }

  let namesController;
  let res;
  before(() => {
    mockRequire('@ibm-cloud/cloudant/cloudant/v1', cloudantMock);

    res = mockRequire.reRequire('express/lib/response');
    sandbox.stub(res, 'json');
    sandbox.spy(res, 'status');

    namesController = mockRequire.reRequire(
      '../../../server/controllers/names-controller',
    );
  });

  afterEach(() => {
    sandbox.reset();
  });

  after(() => {
    sandbox.restore();
    mockRequire.stopAll();
  });

  it('should fail getting names', () => {
    const mockReq = {};

    const resultPromise = namesController.getNames(mockReq, res);

    expect(resultPromise).to.eventually.be.fulfilled
      .then(() => {
        expect(res.status).to.have.been.calledOnceWith(500);
        expect(res.json).to.have.been.calledOnceWith({
          message: 'Get names failed.',
          error: 'There was an error with postAllDocs.',
        });
      });
  });

  it('should fail to add a name', () => {
    const mockReq = {
      body: {
        name: 'name',
        timestamp: 'timestamp',
      },
    };

    const resultPromise = namesController.addName(mockReq, res);
    expect(resultPromise).to.eventually.be.fulfilled
      .then(() => {
        expect(res.status).to.have.been.calledOnceWith(500);
        expect(res.json).to.have.been.calledOnceWith({
          message: 'Add name failed.',
          error: 'There was an error with postDocument.',
        });
      });
  });
});
