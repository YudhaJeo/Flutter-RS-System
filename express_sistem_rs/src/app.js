// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\src\app.js
import express from 'express';
import cors from 'cors';
import authRoutes from './routes/authRoutes.js'
import profileRoutes from './routes/profileRoutes.js';
import reservasiRoutes from './routes/reservasiRoutes.js'
import poliRoutes from './routes/poliRoutes.js'
import dokterRoutes from './routes/dokterRoutes.js'
import dompetMedisRoutes from './routes/dompetMedisRoutes.js';
import kalenderRoutes from './routes/kalenderRoutes.js';
import rekammedisRoutes from './routes/rekamMedisRoutes.js';
import riwayatJalanRoutes from './routes/riwayatJalanRoutes.js';
import riwayatInapRoutes from './routes/riwayatInapRoutes.js';
import beritaRoutes from './routes/beritaRoutes.js';
import kritikSaranRoutes from './routes/kritikSaranRoutes.js';

const app = express();
app.use(express.urlencoded({ extended: true }));

app.use(cors({ 
  origin: '*', 
  credentials: false 
}));

app.use(express.json());

app.use((req, res, next) => {
  next();
});

app.use('/login', authRoutes);
app.use('/profile', profileRoutes);
app.use('/reservasi', reservasiRoutes);
app.use('/poli', poliRoutes);
app.use('/dokter', dokterRoutes);
app.use('/dompet_medis', dompetMedisRoutes);
app.use('/kalender', kalenderRoutes);
app.use('/rekam_medis', rekammedisRoutes);
app.use('/riwayat_jalan', riwayatJalanRoutes);
app.use('/riwayat_inap', riwayatInapRoutes);
app.use('/berita', beritaRoutes);
app.use('/kritik_saran', kritikSaranRoutes);

export default app;