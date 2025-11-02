import * as profileModel from '../models/profileTentangModel.js';

export async function getAllprofile(req, res) {
    try {
        const profile = await profileModel.getAll();
        res.json(profile);
    } catch (err) {
        console.error('Error backend:', err);
        res.status(500).json({ error: err.message });
    }
}

export async function getprofileById(req, res) {
    try {
        const id = req.params.id;
        const profile = await profileModel.getById(id);
        if (!profile) return res.status(404).json({ error: 'profile tidak ditemukan' });
        res.json(profile);
    } catch (err) {
        console.error('Error backend:', err);
        res.status(500).json({ error: err.message });
    }
}
