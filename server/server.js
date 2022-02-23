// import dependencies and initialize express
import express from 'express';
import path from 'path';
import bodyParser from 'body-parser';
import helmet from 'helmet';

import { fileURLToPath } from 'url';

import nameRoutes from './routes/names-route.js';
import healthRoutes from './routes/health-route.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// enable parsing of http request body
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// if production, enable helmet
/* c8 ignore next 3  */
if (process.env.VCAP_APPLICATION) {
  app.use(helmet());
}

// access to static files
app.use(express.static(path.join('public')));

// routes and api calls
app.use('/health', healthRoutes);
app.use('/api/names', nameRoutes);

// error handler for unmatched routes or api calls
app.use((req, res, next) => {
  res.sendFile(path.join(__dirname, '../public', '404.html'));
});

// start node server
const port = process.env.PORT || 3000;
const server = app.listen(port, () => {
  console.log(`App UI available http://localhost:${port}`);
});

export default server;
