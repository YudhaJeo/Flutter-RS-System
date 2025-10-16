import * as PoliModel from '../models/poliModel.js';

export async function getAllPoli(req, res) {
    try {
        const poli = await PoliModel.getAll();
        res.json(poli);
    } catch (err) {
        console.error('Error backend:', err);
        res.status(500).json({ error: err.message });
    }
}

export async function getPoliById(req, res) {
    try {
        const id = req.params.id;
        const poli = await PoliModel.getById(id);
        if (!poli) return res.status(404).json({ error: 'Poli tidak ditemukan' });
        res.json(poli);
    } catch (err) {
        console.error('Error backend:', err);
        res.status(500).json({ error: err.message });
    }
}
