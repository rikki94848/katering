const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth');
const { daysInclusive } = require('../utils/dates');

function ordersRoutes(db) {
  const router = express.Router();

  // client create order
  router.post('/', requireAuth, requireRole('client'), async (req, res) => {
    try {
      const {
        package_id,
        start_date,
        end_date,
        portions,
        delivery_address,
        notes,
        shipping_fee,
        discount
      } = req.body || {};

      if (!package_id || !start_date || !end_date || !portions || !delivery_address) {
        return res.status(400).json({ message: 'package_id, start_date, end_date, portions, delivery_address required' });
      }

      const days_count = daysInclusive(start_date, end_date);
      if (days_count <= 0 || days_count > 31) {
        return res.status(400).json({ message: 'Invalid date range (max 31 days)' });
      }

      // fetch package
      const [pkgRows] = await db.execute(
        `SELECT * FROM packages WHERE id=? AND is_active=1 LIMIT 1`,
        [Number(package_id)]
      );
      const pkg = pkgRows && pkgRows[0];
      if (!pkg) return res.status(400).json({ message: 'Invalid package' });

      const p = Number(portions);
      const ship = Number(shipping_fee || 0);
      const disc = Number(discount || 0);

      const subtotal = Number(pkg.price_per_portion_per_day) * p * days_count;
      const total = Math.max(0, subtotal + ship - disc);

      const [result] = await db.execute(
        `INSERT INTO orders
          (user_id, package_id, start_date, end_date, days_count, portions, delivery_address, notes, shipping_fee, discount, subtotal, total, status)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        [
          req.user.id,
          Number(package_id),
          start_date,
          end_date,
          days_count,
          p,
          delivery_address,
          notes || '',
          ship,
          disc,
          subtotal,
          total,
          'pending'
        ]
      );

      return res.json({ id: result.insertId, subtotal, total, status: 'pending' });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  // client orders
  router.get('/my', requireAuth, requireRole('client'), async (req, res) => {
    try {
      const [rows] = await db.execute(
        `SELECT o.*, p.name AS package_name
         FROM orders o
         JOIN packages p ON p.id = o.package_id
         WHERE o.user_id=?
         ORDER BY o.id DESC`,
        [req.user.id]
      );
      return res.json(rows);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  // admin list orders
  router.get('/admin', requireAuth, requireRole('admin'), async (req, res) => {
    try {
      const [rows] = await db.execute(
        `SELECT o.*, u.name AS client_name, u.email AS client_email, p.name AS package_name
         FROM orders o
         JOIN users u ON u.id = o.user_id
         JOIN packages p ON p.id = o.package_id
         ORDER BY o.id DESC`
      );
      return res.json(rows);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  // admin update status
  router.patch('/admin/:id/status', requireAuth, requireRole('admin'), async (req, res) => {
    try {
      const id = Number(req.params.id);
      const { status } = req.body || {};
      const allowed = new Set(['pending','approved','processing','delivering','done','rejected']);
      if (!allowed.has(status)) return res.status(400).json({ message: 'Invalid status' });

      const [result] = await db.execute(
        `UPDATE orders SET status=? WHERE id=?`,
        [status, id]
      );
      return res.json({ updated: result.affectedRows });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  // admin sales report
  router.get('/admin/reports/sales', requireAuth, requireRole('admin'), async (req, res) => {
    try {
      const { from, to } = req.query || {};
      if (!from || !to) return res.status(400).json({ message: 'from and to required (YYYY-MM-DD)' });

      const [rows] = await db.execute(
        `SELECT COALESCE(SUM(total),0) AS omzet, COUNT(*) AS orders_done
         FROM orders
         WHERE status='done' AND DATE(created_at) BETWEEN ? AND ?`,
        [from, to]
      );

      return res.json(rows[0] || { omzet: 0, orders_done: 0 });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  return router;
}

module.exports = { ordersRoutes };
