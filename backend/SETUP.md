# Backend Laravel 11 - Setup Instructions

## 📋 Next Steps (Bisa Dilakukan Otomatis atau Manual)

Semua file sudah selesai dibuat. Lakukan setup berikut kapan saja ketika siap menjalankan backend:

### 🚀 Setup Otomatis (Recommended)

**Windows (PowerShell):**
```powershell
cd backend
.\auto-setup.ps1
```

**Linux/Mac/Git Bash:**
```bash
cd backend
chmod +x auto-setup.sh
./auto-setup.sh
```

**Full Setup (dengan queue worker):**
```powershell
# Windows
.\auto-setup-full.ps1
```

Script akan otomatis:
1. ✅ Rebuild backend container
2. ✅ Run migrations
3. ✅ Generate app key
4. ✅ Optimize application (cache config & routes)

### 📝 Setup Manual

### 1. Rebuild Backend Container

Install dependencies baru (Sanctum, Guzzle, Spatie Permission):

```bash
docker-compose build backend
docker-compose up -d backend
```

**Mengapa perlu?**
- Dependencies baru di `composer.json` belum terinstall
- Tanpa ini, backend akan error karena class tidak ditemukan

### 2. Run Migrations

Buat database tables:

```bash
docker-compose exec backend php artisan migrate
```

**Mengapa perlu?**
- Database tables belum ada (users, trends, scheduled_posts, dll)
- API endpoints akan error tanpa tables

### 3. Generate App Key (Optional)

Generate application encryption key:

```bash
docker-compose exec backend php artisan key:generate
```

**Mengapa perlu?**
- Untuk security (password hashing, token encryption)
- Bisa di-skip jika tidak urgent, tapi recommended

## 🚀 Quick Start (Semua Command Sekaligus)

```bash
# Rebuild backend
docker-compose build backend
docker-compose up -d backend

# Wait a few seconds for container to start
sleep 5

# Run migrations
docker-compose exec backend php artisan migrate

# Generate app key (optional)
docker-compose exec backend php artisan key:generate
```

## ✅ Verifikasi

Setelah setup, test API:

```bash
# Health check
curl http://localhost/api/health

# API info
curl http://localhost/api/
```

## 📝 Catatan

- **Tidak perlu dilakukan sekarang** - bisa dilakukan nanti kapan saja
- **Harus dilakukan sebelum menggunakan API** - kalau tidak, endpoints akan error
- **File-file sudah lengkap** - tinggal run commands di atas

## 🔧 Troubleshooting

Jika ada error:

1. **Error: Class not found**
   - Pastikan sudah rebuild: `docker-compose build backend`

2. **Error: Table doesn't exist**
   - Pastikan sudah run migrations: `docker-compose exec backend php artisan migrate`

3. **Error: No application encryption key**
   - Run: `docker-compose exec backend php artisan key:generate`

