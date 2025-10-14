// D:\Mobile App\flutter_sistem_rs\server\server.js
import { config } from 'dotenv';
import { createServer } from 'http';
import app from './src/app.js';

config();

const PORT = process.env.PORT;
const EXPRESS_URL = process.env.EXPRESS_PUBLIC_URL;

const server = createServer(app);

server.listen(PORT, () => {
  console.log(`🚀 Server berjalan di ${EXPRESS_URL}`);
});