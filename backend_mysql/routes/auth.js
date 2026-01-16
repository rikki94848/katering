const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function isDuplicateKeyErr(err) {
  return err && (err.code === 'ER_DUP_ENTRY' || err.errno === 1062);
}

function authRoutes(db) {
  const router = express.Router();

  router.post('/register', async (req, res) => {
    try {
      const { name, email, password } = req.body || {};
      if (!name || !email || !password) {
        return res.status(400).json({ message: 'name, email, password required' });
      }

      const password_hash = await bcrypt.hash(password, 10);
      const em = normalizeEmail(email);

      const [result] = await db.execute(
        `INSERT INTO users (name, email, password_hash, role, is_approved)
         VALUES (?,?,?,?,?)`,
        [name, em, password_hash, 'client', 0]
      );

      return res.json({ id: result.insertId, message: 'Registered. Waiting admin approval.' });
    } catch (err) {
      if (isDuplicateKeyErr(err)) return res.status(400).json({ message: 'Email already used' });
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  // Use once to seed an admin account
  router.post('/register-admin', async (req, res) => {
    try {
      const { name, email, password } = req.body || {};
      if (!name || !email || !password) {
        return res.status(400).json({ message: 'name, email, password required' });
      }

      const password_hash = await bcrypt.hash(password, 10);
      const em = normalizeEmail(email);

      const [result] = await db.execute(
        `INSERT INTO users (name, email, password_hash, role, is_approved)
         VALUES (?,?,?,?,?)`,
        [name, em, password_hash, 'admin', 1]
      );

      return res.json({ id: result.insertId, message: 'Admin registered' });
    } catch (err) {
      if (isDuplicateKeyErr(err)) return res.status(400).json({ message: 'Email already used' });
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  router.post('/login', async (req, res) => {
    try {
      const { email, password } = req.body || {};
      if (!email || !password) return res.status(400).json({ message: 'email, password required' });

      const em = normalizeEmail(email);
      const [rows] = await db.execute(`SELECT * FROM users WHERE email = ? LIMIT 1`, [em]);
      const row = rows && rows[0];
      if (!row) return res.status(401).json({ message: 'Invalid credentials' });

      const ok = await bcrypt.compare(password, row.password_hash);
      if (!ok) return res.status(401).json({ message: 'Invalid credentials' });

      const token = jwt.sign({ id: row.id, role: row.role }, process.env.JWT_SECRET, { expiresIn: '7d' });

      // Keep behavior same as SQLite version
      if (row.role === 'client' && Number(row.is_approved) !== 1) {
        return res.json({ token, role: row.role, isApproved: false, name: row.name });
      }

      return res.json({ token, role: row.role, isApproved: true, name: row.name });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: 'DB error' });
    }
  });

  return router;
}

module.exports = { authRoutes };
