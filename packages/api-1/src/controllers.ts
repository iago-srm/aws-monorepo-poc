import { Request, Response } from 'express';

export const Ping = (req: Request, res: Response) => {
    
    return res.send(`Pong - server 1 - v3.1 - ${process.env.DATABASE_URL}`);
}

export const HealthCheck = (req: Request, res: Response) => {
    
    return res.sendStatus(200);
}

