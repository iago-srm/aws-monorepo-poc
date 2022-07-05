import { Request, Response } from 'express';

export const Ping = (req: Request, res: Response) => {
    
    return res.send("Pong - server 1");
}