import * as JadwalModel from '../models/kalenderModel.js';

export async function getAllJadwal(req, res) {
    try {
        const jadwal = await JadwalModel.getAll();
        res.json(jadwal);
    } catch (err) {
        console.error('Error backend:', err);
        res.status(500).json({ error: err.message });
    }
}

export async function getJadwalById(req, res) {
    try {
        const id = req.params.id;
        const jadwal = await JadwalModel.getById(id);
        if (!jadwal) return res.status(404).json({ error: 'Jadwal tidak ditemukan' });
        res.json(jadwal);
    } catch (err) {
        console.error('Error backend:', err);
        res.status(500).json({ error: err.message });
    }
}
