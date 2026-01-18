# 🍱 Bigmo Katering

**Bigmo Katering** adalah aplikasi mobile berbasis *pre-order* yang dirancang untuk mempermudah pemesanan paket katering harian secara praktis dan rapi. Aplikasi ini memisahkan peran antara **Client** (Pelanggan) dan **Admin** (Pengelola) untuk manajemen pesanan yang efisien.

Proyek ini diajukan untuk memenuhi **Ujian Akhir Semester (UAS) Pemrograman Mobile** Semester Ganjil 2025/2026 di Institut Teknologi Nasional Bandung.

---

## 👥 Tim Pengembang (Developer Team)

| Nama Mahasiswa | NPM | Peran |
| :--- | :--- | :--- |
| **Ananda Permana Mulyadi** | 15-2022-086 | Developer |
| **Rikki Subagja** | 15-2022-055 | Developer |
| **Aji Rahman Nugraha** | 15-2022-060 | Developer |


---

## 📱 Fitur Unggulan

Aplikasi ini mencakup spesifikasi teknis sebagai berikut:

### 1. Sistem Approval User (Admin Control) 🛡️
Fitur keamanan di mana pengguna baru (Client) yang mendaftar **tidak bisa langsung login**. Data mereka masuk ke status *Pending* dan wajib di-*approve* oleh Admin terlebih dahulu melalui Admin Console.

### 2. Integrasi API Public (TheMealDB) 🍲
Fitur **"Inspirasi Menu"** yang mengambil data resep makanan internasional secara *real-time* dari API [TheMealDB](https://www.themealdb.com). Membantu user mencari ide menu makanan.

### 3. Manajemen Pesanan (CRUD) 📝
* **Client:** Dapat memilih paket (Super Ultra, Standar, Sultan, Hemat), menentukan tanggal, dan melihat riwayat pesanan.
* **Admin:** Mengelola status pesanan (*Approved -> Processing -> Delivering -> Done*) dan mengelola daftar paket katering.

### 4. Laporan & Visualisasi Data 📊
Admin Dashboard dilengkapi dengan **Grafik Penjualan (Line Chart)** untuk memantau tren pendapatan/omzet dalam periode tertentu.

### 5. Fitur Chat & Lokasi 📍💬
* **Live Chat:** Diskusi pesanan antara Client dan Admin secara *real-time* menggunakan Firebase.
* **Lokasi Katering:** Integrasi Peta untuk melihat lokasi dapur fisik katering.

---

## 🛠️ Teknologi (Tech Stack)

Aplikasi ini dibangun menggunakan teknologi berikut:

* **Frontend Mobile:** Flutter (Dart)
* **Backend API:** Node.js Express
* **Database:** MySQL
* **Realtime Service:** Firebase (untuk Chat)

---

## 📸 Dokumentasi Aplikasi

Berikut adalah tampilan antarmuka aplikasi Bigmo Katering:

### A. Tampilan Umum & Autentikasi
| Loading Screen | Login / Register |
| :---: | :---: |
| <img src="katering_preorder/assets/screenshots/loading.png" width="200" alt="Loading" /> | <img src="katering_preorder/assets/screenshots/login.png" width="200" alt="Login" /> |
| *Loading screen awal saat aplikasi dibuka.* | *Form login dan registrasi akun baru (Client & Admin).* |

---

### B. Fitur Admin (Pengelola)
Admin memiliki hak akses penuh untuk mengelola operasional katering.

| 1. Dashboard Approval | 2. Kelola Paket | 3. Tambah Paket |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/admin_approval.png" width="200" /> | <img src="katering_preorder/assets/screenshots/admin_paket.png" width="200" /> | <img src="katering_preorder/assets/screenshots/admin_add_paket.png" width="200" /> |
| *Laman approval user yang baru mendaftar.* | *Daftar paket makanan yang akan dipilih user.* | *Form penambahan paket baru oleh Admin.* |

| 4. Proses Pesanan | 5. Riwayat Pesanan | 6. Diskusi Pesanan |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/admin_proses.png" width="200" /> | <img src="katering_preorder/assets/screenshots/admin_history.png" width="200" /> | <img src="katering_preorder/assets/screenshots/chat.png" width="200" /> |
| *Kelola status pesanan client yang berjalan.* | *Riwayat pemesanan yang telah selesai.* | *Diskusi live chat antara Admin dan User.* |

| 7. Laporan Penjualan | 8. Grafik Penjualan |
| :---: | :---: |
| <img src="katering_preorder/assets/screenshots/laporan.png" width="200" /> | <img src="katering_preorder/assets/screenshots/grafik.png" width="200" /> |
| *Laporan omzet dan keuntungan.* | *Visualisasi grafik tren pendapatan.* |

---

### C. Fitur Customer (Pelanggan)
Client dapat melihat menu, memesan, dan melacak pesanan.

| 1. Dashboard User | 2. Inspirasi Menu | 3. Daftar Paket |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/register.png" width="200" /> | <img src="katering_preorder/assets/screenshots/inspirasi.png" width="200" /> | <img src="katering_preorder/assets/screenshots/client_paket.png" width="200" /> |
| *Register user.* | *Rekomendasi masakan (Integrasi API).* | *Pilihan paket katering untuk dibeli.* |

| 4. Pesanan & Riwayat | 5. Ulasan Produk | 6. Lokasi Katering |
| :---: | :---: | :---: |
| <img src="katering_preorder/assets/screenshots/client_order.png" width="200" /> | <img src="katering_preorder/assets/screenshots/ulasan.png" width="200" /> | <img src="katering_preorder/assets/screenshots/lokasi.png" width="200" /> |
| *Status pesanan aktif & riwayat.* | *Form ulasan/rating untuk paket.* | *Peta lokasi fisik dapur katering.* |

| 7. Tentang Aplikasi |
| :---: |
| <img src="katering_preorder/assets/screenshots/about.png" width="200" /> |
| *Informasi pengembang & versi aplikasi.* |

---

## 🚀 Cara Instalasi

1.  **Clone Repository**
    ```bash
    git clone [https://github.com/rikki94848/katering.git](https://github.com/rikki94848/katering.git)
    ```

2.  **Setup Database**
    * Import file database SQL (terlampir di folder `database/`) ke MySQL Anda.
    * Pastikan backend Node.js berjalan dan terkoneksi ke database.

3.  **Jalankan Aplikasi**
    ```bash
    flutter pub get
    flutter run
    ```

---
Copyright © 2026 - Bigmo Katering
