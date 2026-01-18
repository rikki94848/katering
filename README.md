# 🍱 Bigmo Katering (Full Stack)

**Bigmo Katering** adalah sistem aplikasi katering terintegrasi yang terdiri dari **Aplikasi Mobile** (untuk Client & Admin) dan **Backend Server** (REST API).

Aplikasi ini dirancang untuk mempermudah pemesanan paket katering harian secara praktis, dengan fitur pemisahan peran antara **Client** (Pelanggan) dan **Admin** (Pengelola).

[cite_start]Proyek ini diajukan untuk memenuhi **Ujian Akhir Semester (UAS) Pemrograman Mobile** Semester Ganjil 2025/2026 di Institut Teknologi Nasional Bandung[cite: 3, 10, 11].

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
    [cite_start]Pengguna baru (Client) masuk ke status *Pending* dan wajib di-*approve* oleh Admin sebelum bisa login[cite: 42].
2.  **Integrasi API Public (TheMealDB) 🍲**
    [cite_start]Fitur "Inspirasi Menu" yang mengambil data resep makanan internasional secara *real-time*[cite: 402].
3.  **Manajemen Pesanan (CRUD) 📝**
    Client memesan paket; [cite_start]Admin mengelola status (*Approved -> Processing -> Delivering -> Done*)[cite: 198].
4.  **Laporan & Visualisasi Data 📊**
    [cite_start]Dashboard Admin dilengkapi Grafik Penjualan untuk memantau tren pendapatan[cite: 226].
5.  **Realtime Chat & Lokasi 📍💬**
    [cite_start]Diskusi pesanan via Firebase dan integrasi peta lokasi dapur[cite: 242, 383].

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

Untuk menjalankan aplikasi ini secara utuh, Anda harus menjalankan **Backend** terlebih dahulu, baru kemudian **Aplikasi Mobile**.

### TAHAP 1: Setup Backend & Database 🗄️

1.  **Siapkan Database:**
    * Buka MySQL (phpMyAdmin/Terminal).
    * Buat database baru bernama: `katering_preorder`.
    * *(Opsional)* Import file SQL jika tersedia di folder `database/`.

2.  **Konfigurasi Environment:**
    * Masuk ke folder backend: `cd backend_mysql`
    * Copy file `.env.example` menjadi `.env`.
    * Pastikan konfigurasi DB sesuai (User: `root`, Pass: ``, DB: `katering_preorder`).

3.  **Jalankan Server:**
    ```bash
    npm install
    npm start
    ```
    *Server akan berjalan di `http://localhost:3000`.*

---

### TAHAP 2: Setup Aplikasi Mobile (Flutter) 📱

1.  **Buka Terminal Baru:**
    Pastikan terminal Backend tetap berjalan, lalu buka terminal baru.

2.  **Masuk ke Folder Mobile:**
    ```bash
    cd katering_preorder
    ```

3.  **Jalankan Aplikasi:**
    ```bash
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
[cite_start]Copyright © 2026 - Bigmo Katering [cite: 70]
