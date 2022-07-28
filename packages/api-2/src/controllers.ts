import { Request, Response } from 'express';
import { commonFunction } from 'common';
import AWS, { S3 } from 'aws-sdk';
import { promisify } from 'util';
import { PrismaClient } from '../generated/client';

export const Ping = (req, res) => res.send(`Pong - Server 2`);


export const HealthCheck = (req: Request, res: Response) => {
    
    return res.sendStatus(200);
}

export const Test = async (req: Request, res: Response) => {
    AWS.config.update({ region: 'us-east-1' });

    const s3 = new AWS.S3({apiVersion: '2006-03-01'});
    const listObjects = promisify(s3.listObjectsV2.bind(s3));
    const objects = await listObjects({
        Bucket: process.env.BUCKET_NAME
    });

    const prisma = new PrismaClient();
    await prisma.user2.create({
        data: {
            name: req.body.name,
            email: req.body.email
        }
    });
    
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
        ${JSON.stringify(response)} |
        ${JSON.stringify(objects)}
    `);
}
