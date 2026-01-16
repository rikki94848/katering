# Katering Pre-Order Backend (Express + MySQL)

Backend REST API untuk aplikasi Katering Pre-Order (Client & Admin).

## 1) Prasyarat
- Node.js (LTS)
- MySQL Server (boleh MySQL Community / XAMPP / Laragon)

## 2) Buat database MySQL
Login ke MySQL, lalu buat database:

```sql
CREATE DATABASE katering_preorder CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

> Tabel akan dibuat otomatis saat server dijalankan.

## 3) Setup env
Copy file contoh env:

```bash
cp .env.example .env
```

Edit `.env` sesuai MySQL kamu:
- `DB_HOST` (umumnya `127.0.0.1`)
- `DB_USER` (umumnya `root`)
- `DB_PASSWORD` (kosong jika XAMPP default)
- `DB_NAME` (`katering_preorder`)
- `JWT_SECRET` (isi bebas)

## 4) Jalankan server
```bash
npm install
npm start
```

API base: `http://localhost:3000/api`

## 5) Seed akun admin (sekali saja)
Pakai Postman/Insomnia atau PowerShell:

Endpoint:
- `POST /api/auth/register-admin`

Body JSON:
```json
{ "name":"Admin", "email":"admin@demo.com", "password":"admin123" }
```

Lalu login:
- `POST /api/auth/login`

> Catatan: `/api/auth/login` itu **POST**, bukan GET.
