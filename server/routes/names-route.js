// import dependencies and initialize the express router
const express = require('express');
const NamesController = require('../controllers/names-controller');

const router = express.Router();

// define routes
router.get('', NamesController.getNames);
router.post('', NamesController.addName);

module.exports = router;
