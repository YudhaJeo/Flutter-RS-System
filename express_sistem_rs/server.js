// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\server\server.js
import { config } from 'dotenv';
import { createServer } from 'http';
import { readFileSync } from 'fs';
import app from './src/app.js';
import admin from 'firebase-admin';

const serviceAccount = JSON.parse(
  readFileSync(new URL('./serviceAccountKey.json', import.meta.url))
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

config({ quiet: true });

const PORT = process.env.PORT;
const EXPRESS_URL = process.env.EXPRESS_PUBLIC_URL;

const server = createServer(app);

server.listen(PORT, () => {
  console.log(`🚀 Server berjalan di ${EXPRESS_URL}`);
});