// D:\Mobile App\flutter_sistem_rs\server\src\app.js
import express from 'express';
import cors from 'cors';
import authRoutes from './routes/authRoutes.js'
import profileRoutes from './routes/profileRoutes.js';
import reservasiRoutes from './routes/reservasiRoutes.js'
import poliRoutes from './routes/poliRoutes.js'
import dokterRoutes from './routes/dokterRoutes.js'


const app = express();
app.use(express.urlencoded({ extended: true }));

app.use(cors({ 
    origin: '*', 
    credentials: false 
}));

app.use(express.json());

app.use('/login', authRoutes);
app.use('/profile', profileRoutes);
app.use('/reservasi', reservasiRoutes);
app.use('/poli', poliRoutes);
app.use('/dokter', dokterRoutes);

export default app;