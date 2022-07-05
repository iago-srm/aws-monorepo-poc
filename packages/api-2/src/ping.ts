import { Request, Response } from 'express';
import { commonFunction } from 'common';
import AWS, { S3 } from 'aws-sdk';
import { promisify } from 'util';

export const Ping = (req, res) => res.send('pong');

export const Test = async (req: Request, res: Response) => {
    AWS.config.update({ region: 'us-west-2' });
    const s3 = new AWS.S3({apiVersion: '2006-03-01'});
    const listBuckets = promisify(s3.listBuckets.bind(s3));
    const buckets = await listBuckets();
    return res.send(`
        Server 2 | 
        ${commonFunction()} | 
        ${JSON.stringify(buckets.Buckets.map(({Name}) => Name))}
    `);
}
