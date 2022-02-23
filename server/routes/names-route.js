// import dependencies and initialize the express router
import express from 'express';
import { body, validationResult } from 'express-validator';

import NamesController from '../controllers/names-controller.js';

const router = express.Router();

// standardized validation error response
const validate = validations => {
  return async(req, res, next) => {
    await Promise.all(validations.map(validation => validation.run(req)));

    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }

    res.status(400).json({ errors: errors.array() });
  };
};

const namesController = new NamesController();

// define routes
router.get('', namesController.getNames);
router.post('', validate([
  body('name').isAlphanumeric(),
  body('timestamp').isISO8601(),
]), namesController.addName);

export default router;
