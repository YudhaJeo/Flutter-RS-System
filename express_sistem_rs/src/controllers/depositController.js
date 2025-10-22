import * as DepositModel from '../models/depositModel.js';

export async function getAllDeposit(req, res) {
  try {
    const data = await DepositModel.getAll();
    res.status(200).json({ success: true, data });
  } catch (err) {
    console.error('Get All Deposit Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
}

export async function getDepositById(req, res) {
  try {
    const { id } = req.params;
    const deposit = await DepositModel.getById(id);

    if (!deposit) {
      return res.status(404).json({ success: false, message: 'Deposit tidak ditemukan' });
    }

    res.status(200).json({ success: true, data: deposit });
  } catch (err) {
    console.error('Get Deposit By ID Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
}

export async function getDepositByUser(req, res) {
  try {
    const { nik } = req.params;
    const data = await DepositModel.getByNik(nik);
    res.status(200).json({ success: true, data });
  } catch (err) {
    console.error('Get Deposit By User Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
}