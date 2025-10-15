// D:\Mobile App\flutter_sistem_rs\server\src\app.js
import express from 'express';
import cors from 'cors';
import authRoutes from './routes/authRoutes.js'
import profileRoutes from './routes/profileRoutes.js';

const app = express();
app.use(express.urlencoded({ extended: true }));

app.use(cors({ 
    origin: '*', 
    credentials: false 
}));

app.use(express.json());

app.use('/login', authRoutes);
app.use('/profile', profileRoutes);

export default app;