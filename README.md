# 🍱 Bigmo Katering (Full Stack)

**Bigmo Katering** adalah sistem aplikasi katering terintegrasi yang terdiri dari **Aplikasi Mobile** (untuk Client & Admin) dan **Backend Server** (REST API).

[cite_start]Aplikasi ini dirancang untuk mempermudah pemesanan paket katering harian secara praktis, dengan fitur pemisahan peran antara **Client** (Pelanggan) dan **Admin** (Pengelola)[cite: 354].

[cite_start]Proyek ini diajukan untuk memenuhi **Ujian Akhir Semester (UAS) Pemrograman Mobile** Semester Ganjil 2025/2026 di Institut Teknologi Nasional Bandung[cite: 1, 3, 11].

---

## 👥 Tim Pengembang (Developer Team)

| Nama Mahasiswa | NPM | Peran |
| :--- | :--- | :--- |
| **Rikki Subagja** | 15-2022-055 | Developer |
| **Aji Rahman Nugraha** | 15-2022-060 | Developer |
| **Ananda Permana Mulyadi** | 15-2022-086 | Developer |

---

## 📱 Fitur Unggulan

1.  **Sistem Approval User (Admin Control) 🛡️**
    Pengguna baru (Client) masuk ke status *Pending* dan wajib di-*approve* oleh Admin sebelum bisa login[cite: 42, 52].
2.  **Integrasi API Public (TheMealDB) 🍲**
    Fitur "Inspirasi Menu" yang mengambil data resep makanan internasional secara *real-time*[cite: 390, 402].
3.  **Manajemen Pesanan (CRUD) 📝**
    Client memesan paket; Admin mengelola status (*Approved -> Processing -> Delivering -> Done*)[cite: 142, 171].
4.  **Laporan & Visualisasi Data 📊**
    Dashboard Admin dilengkapi Grafik Penjualan untuk memantau tren pendapatan[cite: 226, 239].
5.  **Realtime Chat & Lokasi 📍💬**
    Diskusi pesanan via Firebase dan integrasi peta lokasi dapur[cite: 188, 355].

---

## 🛠️ Teknologi (Tech Stack)

| Komponen | Teknologi | Keterangan |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | [cite_start]Aplikasi Mobile (Android) [cite: 365] |
| **Backend** | Node.js + Express | [cite_start]REST API Server [cite: 366] |
| **Database** | MySQL | [cite_start]Penyimpanan Data Relasional [cite: 367] |
| **Realtime** | Firebase Firestore | Fitur Live Chat |

---

## 🚀 Panduan Instalasi (Step-by-Step)

Untuk menjalankan aplikasi ini secara utuh, silakan ikuti urutan berikut:

### 1️⃣ Setup Database & Backend 🗄️

1.  **Database MySQL:**
    * Buat database baru di phpMyAdmin bernama: `katering_preorder`.
    * Import file SQL yang ada di folder `database/katering.sql`.

2.  **Jalankan Server Backend:**
    Buka terminal dan masuk ke folder backend:
    ```bash
    cd backend_mysql
    npm install
    npm start
    ```
    *Server akan berjalan di `http://localhost:3000`.*

### 2️⃣ Setup Aplikasi Mobile (Flutter) 📱

1.  **Buka Terminal Baru:**
    Biarkan terminal backend tetap berjalan, buka terminal/tab baru.

2.  **Jalankan Aplikasi:**
    Masuk ke folder aplikasi mobile:
    ```bash
    cd katering_preorder
    flutter pub get
    flutter run
    ```

---

## 📸 Dokumentasi Lengkap Aplikasi

Berikut adalah dokumentasi UI sesuai dengan laporan pengembangan:

### [cite_start]A. Tampilan Umum & Autentikasi [cite: 23]
| Loading Screen | Login / Register |
| :---: | :---: |
| <img src="katering_preorder/assets/screenshots/loading.png" width="200" alt="Loading" /> | <img src="katering_preorder/assets/screenshots/login.png" width="200" alt="Login" /> |
| *Loading Screen* | *Form Masuk & Daftar* |

---

### [cite_start]B. Fitur Admin (Pengelola) [cite: 59]
Admin memiliki hak akses penuh untuk mengelola operasional katering.

| 1. [cite_start]Dashboard Approval [cite: 60] | 2. [cite_start]Kelola Paket [cite: 80] | 3. [cite_start]Tambah Paket [cite: 107] |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/admin_approval.png" width="200" /> | <img src="katering_preorder/assets/screenshots/admin_paket.png" width="200" /> | <img src="katering_preorder/assets/screenshots/admin_add_paket.png" width="200" /> |
| *Approve User Pending* | *List Paket Makanan* | *Form Input Paket* |

| 4. [cite_start]Proses Pesanan [cite: 127] | 5. [cite_start]Riwayat Pesanan [cite: 153] | 6. [cite_start]Diskusi Pesanan [cite: 182] |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/admin_proses.png" width="200" /> | <img src="katering_preorder/assets/screenshots/admin_history.png" width="200" /> | <img src="katering_preorder/assets/screenshots/chat.png" width="200" /> |
| *Update Status Pesanan* | *History Transaksi* | *Live Chat Admin* |

| 7. [cite_start]Laporan Penjualan [cite: 189] | 8. [cite_start]Grafik Penjualan [cite: 219] |
| :---: | :---: |
| <img src="katering_preorder/assets/screenshots/laporan.png" width="200" /> | <img src="katering_preorder/assets/screenshots/grafik.png" width="200" /> |
| *Ringkasan Omzet* | *Visualisasi Grafik* |

---

### [cite_start]C. Fitur Customer (Pelanggan) [cite: 228]
Client dapat melihat menu, memesan, dan melacak pesanan.

| 1. [cite_start]Dashboard User [cite: 229] | 2. [cite_start]Inspirasi Menu [cite: 246] | 3. [cite_start]Daftar Paket [cite: 296] |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/client_home.png" width="200" /> | <img src="katering_preorder/assets/screenshots/inspirasi.png" width="200" /> | <img src="katering_preorder/assets/screenshots/client_paket.png" width="200" /> |
| *Halaman Utama* | *Integrasi TheMealDB* | *Pilih Paket* |

| 4. [cite_start]Pesanan & Riwayat [cite: 321] | 5. [cite_start]Ulasan Produk [cite: 336] | 6. [cite_start]Tentang Aplikasi [cite: 349] |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/client_order.png" width="200" /> | <img src="katering_preorder/assets/screenshots/ulasan.png" width="200" /> | <img src="katering_preorder/assets/screenshots/about.png" width="200" /> |
| *Tracking Order* | *Rating & Review* | *Info Developer* |

| 7. [cite_start]Lokasi Katering [cite: 369] |
| :---: |
| <img src="katering_preorder/assets/screenshots/lokasi.png" width="200" /> |
| *Maps Lokasi Dapur* |

---
Copyright © 2026 - Bigmo Katering
