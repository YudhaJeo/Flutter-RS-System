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

export async function getDokterByPoli(req, res) {
    try {
        const idPoli = req.params.idPoli;
        const dokters = await DokterModel.getAllDokter();

        const filtered = dokters.filter((d) => d.IDPOLI == idPoli);

        if (filtered.length === 0) {
            return res.status(404).json({ message: 'Tidak ada dokter di poli ini' });
        }

        res.json(filtered);
    } catch (err) {
        console.error('Error:', err);
        res.status(500).json({ error: err.message });
    }
}