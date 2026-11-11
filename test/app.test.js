const test = require('node:test');
const assert = require('node:assert');
const request = require('supertest');
const app = require('../src/app');

test('GET / responde 200 com Hello World', async () => {
  const res = await request(app).get('/');
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.text, 'Hello World');
});
