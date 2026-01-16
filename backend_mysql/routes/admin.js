const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth');

function adminRoutes(db) {
  const router = express.Router();

  router.get('/users/pending', requireAuth, requireRole('admin'), async (req, res) => {
    try {
      const [rows] = await db.execute(
        `SELECT id, name, email, role, is_approved, created_at
         FROM users
         WHERE role='client' AND is_approved=0
         ORDER BY id DESC`
      );
      return res.json(rows);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  router.patch('/users/:id/approve', requireAuth, requireRole('admin'), async (req, res) => {
    try {
      const id = Number(req.params.id);
      const [result] = await db.execute(
        `UPDATE users SET is_approved=1 WHERE id=? AND role='client'`,
        [id]
      );
      return res.json({ updated: result.affectedRows });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  return router;
}

module.exports = { adminRoutes };
