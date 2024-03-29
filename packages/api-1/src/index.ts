import express from "express";
import cors from "cors";
import { AddressInfo } from "net";
import { Ping, HealthCheck, Test } from './controllers';
import dotenv from 'dotenv';
import 'express-async-errors';

dotenv.config();

const app = express();

app.use(express.json());
app.use(cors());

const server = app.listen(process.env.PORT || 3008, () => {
  if (server) {
    const address = server.address() as AddressInfo;
    console.log(`Server is running in ${address.address}:${address.port}`);
  } else {
    console.error(`Failure upon starting server.`);
  }
});

app.get('/', HealthCheck);
app.get('/api-1/ping', Ping);
app.post('/api-1/test', Test);

app.use((err, req, res, _) => {
  res.status(500).send(err);
});