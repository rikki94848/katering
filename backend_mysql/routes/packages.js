const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth');

function packagesRoutes(db) {
  const router = express.Router();

  // visible for logged-in users
  router.get('/', requireAuth, async (req, res) => {
    try {
      const [rows] = await db.execute(
        `SELECT * FROM packages WHERE is_active = 1 ORDER BY id DESC`
      );
      return res.json(rows);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  // admin CRUD
  router.post('/', requireAuth, requireRole('admin'), async (req, res) => {
    try {
      const { name, price_per_portion_per_day, description, is_active } = req.body || {};
      if (!name || price_per_portion_per_day == null) {
        return res.status(400).json({ message: 'name and price required' });
      }

      const active = (is_active === false || is_active === 0) ? 0 : 1;

      const [result] = await db.execute(
        `INSERT INTO packages (name, price_per_portion_per_day, description, is_active)
         VALUES (?,?,?,?)`,
        [name, Number(price_per_portion_per_day), description || '', active]
      );

      return res.json({ id: result.insertId });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  router.put('/:id', requireAuth, requireRole('admin'), async (req, res) => {
    try {
      const id = Number(req.params.id);
      const { name, price_per_portion_per_day, description, is_active } = req.body || {};
      const active = (is_active === true || is_active === 1) ? 1 : 0;

      const [result] = await db.execute(
        `UPDATE packages
         SET name=?, price_per_portion_per_day=?, description=?, is_active=?
         WHERE id=?`,
        [name, Number(price_per_portion_per_day), description || '', active, id]
      );

      return res.json({ updated: result.affectedRows });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  router.delete('/:id', requireAuth, requireRole('admin'), async (req, res) => {
    try {
      const id = Number(req.params.id);
      const [result] = await db.execute(`DELETE FROM packages WHERE id=?`, [id]);
      return res.json({ deleted: result.affectedRows });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  return router;
}

module.exports = { packagesRoutes };
