import * as Model from '../models/riwayatJalanModel.js';

export async function getById(req, res) {
  try {
    const id = req.params.id;
    const data = await Model.getById(id);

    if (!data) {
      return res.status(404).json({ error: 'Data tidak ditemukan' });
    }

    res.json({ data });

    console.log("Data rajal backend:", data)

  } catch (err) {
    console.error('Error getById:', err);
    res.status(500).json({ error: err.message });
  }
}
