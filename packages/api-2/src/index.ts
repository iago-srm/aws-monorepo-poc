import express from "express";
import cors from "cors";
import { AddressInfo } from "net";
import { Ping, Test, HealthCheck } from './controllers';
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

app.get('/test', Test);
app.get('/ping', Ping);
app.get('/', HealthCheck);

export default app;