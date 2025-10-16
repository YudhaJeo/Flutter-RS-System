import * as DokterModel from '../models/dokterModel.js';

export async function getAllDokter(req, res) {
    try {
        const dokters = await DokterModel.getAllDokter();
        res.json(dokters);
    } catch (err) {
        console.error('Error:', err);
        res.status(500).json({ error: err.message });
    }
}

export async function getDokterById(req, res) {
    try {
        const id = req.params.id;
        const dokter = await DokterModel.getDokterById(id);
        if (!dokter) return res.status(404).json({ error: 'Dokter tidak ditemukan' });
        res.json(dokter);
    } catch (err) {
        console.error('Error:', err);
        res.status(500).json({ error: err.message });
    }
}
