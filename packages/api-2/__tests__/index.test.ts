import request from 'supertest';
import app from '../src/index';

describe("Integration test", () => {
    test("First test", async () => {
        const response = await request(app).get('/test');
        expect(response.text).toBe("pong");
    })
})