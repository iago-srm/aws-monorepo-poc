import { Request, Response } from 'express';
import { commonFunction } from 'common';
import AWS, { S3 } from 'aws-sdk';
import { promisify } from 'util';

export const Ping = (req, res) => res.send(`Pong - Server 2 - v3.1 - ${process.env.DATABASE_URL}`);


export const HealthCheck = (req: Request, res: Response) => {
    
    return res.sendStatus(200);
}

export const Test = async (req: Request, res: Response) => {
    AWS.config.update({ region: 'us-west-2' });

    const s3 = new AWS.S3({apiVersion: '2006-03-01'});
    const listBuckets = promisify(s3.listBuckets.bind(s3));
    const buckets = await listBuckets();
    
    const sqs = new AWS.SQS({apiVersion: '2012-11-05'});
    const sendMessage = promisify(sqs.sendMessage.bind(sqs));
    const message = {
        // Remove DelaySeconds parameter and value for FIFO queues
       DelaySeconds: 10,
       MessageBody: {
           attr: 1,
           attr2: "nome",
           attr3: [1,2,3]
       },
       QueueUrl: process.env.SQS_URL
     };
    const response = await sendMessage(message);
    
    return res.send(`
        Server 2 | 
        ${commonFunction()} | 
        ${JSON.stringify(buckets.Buckets.map(({Name}) => Name))}
    `);
}
