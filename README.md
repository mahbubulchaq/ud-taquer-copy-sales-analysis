# ud-taquer-copy-sales-analysis

# Analisis Penjualan & Efisiensi Operasional — UD Taquer Copy

## Latar Belakang & Masalah Bisnis
**UD Taquer Copy** adalah unit dagang percetakan dan fotokopi yang memiliki dua cabang(**Outlet Utama (Pusat)** dan **Outlet Cabang Kampus**). Meskipun kunjungan pelanggan harian cukup stabil, manajemen belum memiliki gambaran jelas mengenai layanan mana yang paling menguntungkan, perbedaan karakter pelanggan antar cabang, serta kendala operasional yang memotong margin keuntungan.

Proyek ini mengolah **3.010 baris data transaksi mentah** (Januari 2025 – Oktober 2026) menjadi data siap analisis menggunakan **SQL** dan menampilkannya ke dalam **dashboard interaktif 1 halaman di Tableau**.

---

## Dataset & Arsitektur Data
Data mentah disusun menggunakan skema bintang yang terdiri dari tiga tabel utama:
1. `raw_transactions`: 3.010 catatan transaksi yang memuat waktu pemesanan, cabang outlet, jalur pemesanan, metode pembayaran, jumlah pesanan, diskon, pendapatan bersih, biaya produksi, dan status pesanan.
2. `raw_customers`: 160 profil pelanggan unik yang dikelompokkan berdasarkan tipe (*Mahasiswa/Pelajar*, *Individu*, *Instansi/Kampus*, *Perusahaan/UMKM*, *Event Organizer*) dan wilayah.
3. `raw_products`: 13 jenis layanan percetakan & fotokopi yang dibagi ke dalam 4 kategori utama (*Fotocopy*, *Buku*, *Cover*, *Undangan*).

---

## Pembersihan Data & Alur Pengolahan SQL
Sebelum divisualisasikan, sebuah tabel tampilan analitik (`vw_taquer_sales_analytics`) dibuat di SQL untuk membersihkan dan menggabungkan data mentah. Langkah perbaikan data yang dilakukan meliputi:
* **Penghapusan Data Ganda:** Menghapus 10 baris transaksi duplikat (mengubah 3.010 baris mentah menjadi **3.000 transaksi unik**) menggunakan `ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY order_datetime ASC)`.
* **Penyeragaman Jalur Pemesanan:** Menyamakan penulisan huruf yang tidak konsisten pada kolom `order_channel` (seperti `walk-in`, `WALK-IN`, `whatsapp order`) menggunakan `INITCAP(TRIM(...))`.
* **Pengisian Data Kosong:** Mengubah nilai kosong pada kolom `payment_method` menjadi `'Tidak Diketahui'` menggunakan `COALESCE(NULLIF(...))`.
* **Perhitungan Keuntungan & Audit Status:** Menghitung lama pengerjaan (`lead_time_days`), laba kotor (`gross_profit`), dan persentase margin (`profit_margin_pct`), serta tetap mempertahankan status `'Dibatalkan'` dan `'Revisi/Cetak Ulang'` untuk mengukur efisiensi operasional.

*Skrip SQL lengkap tersedia di [`sql/data_cleaning_and_modeling.sql`](sql/data_cleaning_and_modeling.sql).*

---

## Temuan Utama Bisnis

1. **Layanan Penarik Pengunjung vs. Layanan Penghasil Omzet Utama**
   * **Layanan Fotocopy** (`PRD-01` Hitam Putih, `PRD-02` Warna, `PRD-03` Jilid Dokumen) menghasilkan frekuensi transaksi harian tertinggi dengan persentase margin tinggi (50%–60%), tetapi nilai per transaksinya kecil.
   * **Cetak Buku** (`PRD-06` Buku Tahunan, `PRD-04` Modul Ajar) dan **Undangan** (`PRD-12` Hardcover Foil) menjadi penyumbang omzet dan laba kotor terbesar per pesanan.

2. **Kebocoran Margin Akibat Revisi/Cetak Ulang**
   * Pesanan berstatus `Revisi/Cetak Ulang` mengalami **kenaikan biaya produksi (`total_cost`) sebesar 20%** tanpa tambahan pendapatan.
   * Pada pesanan bernilai tinggi seperti Buku Tahunan (`PRD-06`), satu kali revisi memangkas margin laba kotor secara drastis dari **40,56% turun menjadi 28,67%**.

3. **Perbedaan Karakteristik Pelanggan Antar Cabang**
   * **Outlet Cabang Kampus** sangat didominasi segmen *Mahasiswa/Pelajar* dengan pesanan utama berupa Hardcover Skripsi (`PRD-08`), Softcover, dan fotokopi harian.
   * **Outlet Utama (Pusat)** lebih banyak menangani pesanan instansi/perusahaan berskala besar (*Instansi/Kampus*, *Event Organizer*) seperti cetak modul kuliah dan ribuan lembar undangan.

4. **Pola Lama Waktu Pengerjaan Pesanan**
   * Layanan fotokopi dan jilid standar rata-rata selesai di hari yang sama (`0–1 hari`), sedangkan cetak buku membutuhkan waktu **3–10 hari** dan undangan memakan waktu **4–14 hari**.

5. **Penggunaan Jalur Digital & Pembayaran Non-Tunai**
   * Jalur digital (**WhatsApp Order**, **Marketplace**, **Email/Web Form**) menyumbang porsi besar mendampingi transaksi langsung ke toko (**Walk-In**).
   * **QRIS** dan **Transfer Bank** mendominasi pembayaran ritel, sedangkan **Invoice Tempo** digunakan khusus oleh klien instansi dan perusahaan.

---

## Rekomendasi Bisnis

1. **Wajibkan Persetujuan Desain Digital Sebelum Cetak Massal**
   * Menerapkan persetujuan tertulis/digital atas contoh desain PDF final dari pelanggan sebelum mencetak produk bernilai tinggi (Buku Tahunan, Buku, Undangan) guna mencegah pembengkakan biaya produksi 20% dan menjaga margin tetap di atas 11%.
2. **Buat Paket Penjualan Sesuai Karakteristik Cabang**
   * **Outlet Cabang Kampus:** Menawarkan paket hemat khusus mahasiswa (*"Paket Print + Softcover + Hardcover Skripsi"*) untuk meningkatkan rata-rata nilai transaksi.
   * **Outlet Utama (Pusat):** Memberikan diskon bertingkat untuk pesanan grosir instansi dan penyelenggara acara.
3. **Optimasi Jadwal Sif Karyawan & Stok Kertas Berdasarkan Jam Sibuk**
   * Menyesuaikan jadwal sif operator dengan jam sibuk yang terlihat pada peta panas (*heatmap*) Tableau, serta menjaga stok aman kertas HVS A4/F4 menjelang musim ujian dan wisuda.

---

## Struktur Repositori
```text
├── data/
│   ├── raw_customers.csv
│   ├── raw_products.csv
│   ├── raw_transactions.csv
│   └── vw_taquer_sales_analytics.csv   # Dataset bersih hasil SQL untuk Tableau
├── sql/
│   └── data_cleaning_and_modeling.sql  # Skrip SQL pembuatan tabel & olah data
├── images/
│   ├── dashboard_page1_sales.png       # Tangkapan layar Tableau Halaman 1
│   └── dashboard_page2_ops.png         # Tangkapan layar Tableau Halaman 2
└── README.md
```

