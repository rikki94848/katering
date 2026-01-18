# 🍱 Bigmo Katering (Full Stack)

**Bigmo Katering** adalah sistem aplikasi katering terintegrasi yang terdiri dari **Aplikasi Mobile** (untuk Client & Admin) dan **Backend Server** (REST API).

Aplikasi ini dirancang untuk mempermudah pemesanan paket katering harian secara praktis, dengan fitur pemisahan peran antara **Client** (Pelanggan) dan **Admin** (Pengelola).

Proyek ini diajukan untuk memenuhi **Ujian Akhir Semester (UAS) Pemrograman Mobile** Semester Ganjil 2025/2026 di Institut Teknologi Nasional Bandung.

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
    Pengguna baru (Client) masuk ke status *Pending* dan wajib di-*approve* oleh Admin sebelum bisa login.
2.  **Integrasi API Public (TheMealDB) 🍲**
    Fitur "Inspirasi Menu" yang mengambil data resep makanan internasional secara *real-time*.
3.  **Manajemen Pesanan (CRUD) 📝**
    Client memesan paket; Admin mengelola status (*Approved -> Processing -> Delivering -> Done*).
4.  **Laporan & Visualisasi Data 📊**
    Dashboard Admin dilengkapi Grafik Penjualan untuk memantau tren pendapatan.
5.  **Realtime Chat & Lokasi 📍💬**
    Diskusi pesanan via Firebase dan integrasi peta lokasi dapur.

---

## 🛠️ Teknologi (Tech Stack)

| Komponen | Teknologi | Keterangan |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | Aplikasi Mobile (Android) |
| **Backend** | Node.js + Express | REST API Server |
| **Database** | MySQL | Penyimpanan Data Relasional |
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

## 📸 Dokumentasi Aplikasi

Berikut adalah tampilan antarmuka aplikasi Bigmo Katering:

### A. Tampilan Umum & Autentikasi
| Loading Screen | Login / Register |
| :---: | :---: |
| <img src="katering_preorder/assets/screenshots/loading.png" width="200" alt="Loading" /> | <img src="katering_preorder/assets/screenshots/login.png" width="200" alt="Login" /> |

### B. Fitur Admin (Pengelola)
| Dashboard Approval | Kelola Paket | Proses Pesanan |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/admin_approval.png" width="200" /> | <img src="katering_preorder/assets/screenshots/admin_paket.png" width="200" /> | <img src="katering_preorder/assets/screenshots/admin_proses.png" width="200" /> |

| Grafik Laporan | Live Chat Admin |
| :---: | :---: |
| <img src="katering_preorder/assets/screenshots/grafik.png" width="200" /> | <img src="katering_preorder/assets/screenshots/chat.png" width="200" /> |

### C. Fitur Client (Pelanggan)
| Dashboard User | Inspirasi Menu (API) | Riwayat Pesanan |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/client_home.png" width="200" /> | <img src="katering_preorder/assets/screenshots/inspirasi.png" width="200" /> | <img src="katering_preorder/assets/screenshots/client_order.png" width="200" /> |

---
Copyright © 2026 - Bigmo Katering
