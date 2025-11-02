# 🚀 Cara Menggunakan Script One-Click

File-file script berikut sudah disiapkan untuk kemudahan Anda. **Cukup double-click** pada file PowerShell (`.ps1`) untuk menjalankannya!

## 📋 Daftar Script yang Tersedia

### 🟢 START.ps1
**Mulai semua layanan aplikasi**
- Cek instalasi Docker
- Buat semua gambar Docker
- Jalankan container
- Setup database (migrations, keys, docs)
- Tampilkan URL akses

**Cara pakai:** Double-click file `START.ps1`

---

### 🔴 STOP.ps1
**Hentikan semua layanan aplikasi**
- Hentikan semua container dengan aman

**Cara pakai:** Double-click file `STOP.ps1`

---

### 🔵 RESTART.ps1
**Restart semua layanan aplikasi**
- Hentikan semua container
- Jalankan kembali semua container
- Tampilkan status terbaru

**Cara pakai:** Double-click file `RESTART.ps1`

---

### 📋 VIEW-LOGS.ps1
**Lihat log aplikasi**
- Pilih layanan yang ingin dilihat log-nya:
  - Semua layanan
  - Backend saja
  - Automation saja
  - Frontend saja
  - Nginx saja
  - Database saja

**Cara pakai:** Double-click file `VIEW-LOGS.ps1`, lalu pilih opsi (1-6)

---

### 🌐 OPEN-WEBSITE.ps1
**Buka aplikasi di browser**
- Pilih website yang ingin dibuka:
  1. Frontend (Main Application)
  2. Backend API (Laravel)
  3. Laravel Docs
  4. FastAPI Docs (Swagger)
  5. FastAPI ReDoc
  6. Grafana Dashboard
  7. Prometheus Metrics
  8. Kibana Logs

**Cara pakai:** Double-click file `OPEN-WEBSITE.ps1`, lalu pilih opsi (1-8)

---

### 📊 QUICK-STATUS.ps1
**Cek status cepat**
- Lihat status semua container
- Lihat URL akses
- Lihat tips penggunaan

**Cara pakai:** Double-click file `QUICK-STATUS.ps1`

---

## 🎯 Alur Penggunaan Normal

### Pertama Kali (Setup Awal)

1. **Pastikan Docker Desktop sudah berjalan**
   - Buka Docker Desktop
   - Tunggu sampai ikon hijau muncul

2. **Double-click `START.ps1`**
   - Script akan mengecek Docker
   - Build semua images (perlu beberapa menit pertama kali)
   - Jalankan semua container
   - Setup database
   - Tampilkan URL akses

3. **Buka aplikasi**
   - Double-click `OPEN-WEBSITE.ps1`
   - Pilih "1" untuk buka Frontend

### Penggunaan Harian

#### Mulai bekerja:
```
Double-click → START.ps1
```

#### Cek status:
```
Double-click → QUICK-STATUS.ps1
```

#### Lihat error/logs:
```
Double-click → VIEW-LOGS.ps1
Pilih opsi yang diinginkan
```

#### Selesai bekerja:
```
Double-click → STOP.ps1
```

#### Ada masalah, butuh restart:
```
Double-click → RESTART.ps1
```

---

## ⚠️ Troubleshooting

### "Docker is not installed"
**Solusi:** Install Docker Desktop dari https://www.docker.com/products/docker-desktop

### "Docker is not running"
**Solusi:**
1. Buka Docker Desktop
2. Tunggu sampai ikon berubah hijau
3. Jalankan script lagi

### "Permission denied" atau script tidak bisa dibuka
**Solusi:**
1. Klik kanan pada file `.ps1`
2. Pilih "Properties"
3. Buka tab "Security"
4. Klik "Unblock" jika ada
5. Atau jalankan manual:
   ```powershell
   PowerShell -ExecutionPolicy Bypass -File START.ps1
   ```

### Container gagal start atau error
**Solusi:**
```
Double-click → STOP.ps1
Double-click → START.ps1
```

Jika masih error, jalankan:
```powershell
docker-compose logs -f
```
Untuk melihat error detailnya.

---

## 🔧 Fitur Tambahan

### Lihat Semua Container
```powershell
docker-compose ps
```

### Akses Bash Shell di Container
```powershell
# Backend
docker exec -it socialtrend_backend bash

# Automation
docker exec -it socialtrend_automation sh
```

### Update Code dan Restart
```
Double-click → STOP.ps1
Double-click → START.ps1
```

---

## 📚 URL Akses

Setelah menjalankan `START.ps1`, aplikasi bisa diakses di:

- **Frontend**: http://localhost
- **Backend API**: http://localhost/api
- **Laravel Docs**: http://localhost/docs
- **FastAPI Swagger**: http://localhost/automation/docs
- **FastAPI ReDoc**: http://localhost/automation/redoc
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Elasticsearch**: http://localhost:9200
- **Kibana**: http://localhost:5601

---

## 💡 Tips

1. **Pertama kali setup** bisa memakan waktu 5-10 menit untuk download images
2. **Selanjutnya** akan lebih cepat karena sudah ada cache
3. **Lihat logs** jika ada masalah untuk troubleshooting
4. **Jangan lupa** jalankan `STOP.ps1` saat selesai untuk hemat resource
5. **Gunakan `QUICK-STATUS.ps1`** untuk cek cepat status aplikasi

---

## 📞 Bantuan

Jika ada masalah:

1. Cek Docker Desktop sudah running
2. Jalankan `QUICK-STATUS.ps1` untuk lihat status
3. Jalankan `VIEW-LOGS.ps1` untuk lihat error detail
4. Coba restart dengan `RESTART.ps1`
5. Jika masih error, buka issue di GitHub

---

**Selamat Mencoba! 🎉**
