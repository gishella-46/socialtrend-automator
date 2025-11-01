# Documentation

Selamat datang di dokumentasi SocialTrend Automator.

## 📚 Dokumentasi Tersedia

### [API Specification](./api-spec.md)
Dokumentasi lengkap semua endpoint dari Laravel API dan FastAPI service, termasuk request/response examples dan error handling.

### [System Architecture](./architecture.md)
Penjelasan arsitektur sistem, diagram alur data, teknologi yang digunakan, dan detail setiap komponen.

### [Deployment Guide](./deployment.md)
Panduan lengkap deployment ke berbagai platform cloud:
- DigitalOcean (Droplets & App Platform)
- AWS ECS (Fargate)
- GCP Cloud Run

## 🔗 API Documentation URLs

### Laravel API Documentation
Setelah menjalankan `php artisan scribe:generate`, dokumentasi akan tersedia di:
- **Local**: `http://localhost:8000/docs`
- **Production**: `https://api.yourdomain.com/docs`

### FastAPI Documentation
FastAPI menyediakan dokumentasi otomatis melalui Swagger UI:
- **Swagger UI**: `http://localhost:5000/docs`
- **ReDoc**: `http://localhost:5000/redoc`
- **OpenAPI JSON**: `http://localhost:5000/openapi.json`

## 🚀 Quick Start

### Generate Laravel API Docs (Scribe)

```bash
cd backend
composer require --dev knuckleswtf/scribe
php artisan vendor:publish --provider="Knuckles\Scribe\ScribeServiceProvider"
php artisan scribe:generate
```

Dokumentasi akan di-generate di `public/docs/`.

### Access FastAPI Docs

FastAPI documentation sudah tersedia secara otomatis di:
- Development: `http://localhost:5000/docs`
- Production: `https://api.yourdomain.com/docs`

## 📖 Struktur Dokumentasi

```
docs/
├── README.md          # File ini
├── api-spec.md        # API Specification (semua endpoint)
├── architecture.md    # System Architecture & Diagrams
└── deployment.md      # Deployment Guides (DO, AWS, GCP)
```

## 🔧 Setup Development

1. **Install Dependencies**
```bash
# Backend (Laravel)
cd backend
composer install

# Automation (FastAPI)
cd ../automation
pip install -r requirements.txt

# Frontend
cd ../frontend
npm install
```

2. **Setup Environment**
```bash
# Copy .env files
cp .env.example .env
```

3. **Generate Laravel Docs**
```bash
cd backend
php artisan scribe:generate
```

4. **Run Services**
```bash
# Docker Compose
docker-compose up -d

# Or individually
# Laravel: php artisan serve
# FastAPI: uvicorn main:app --reload
# Frontend: npm run dev
```

## 📝 Contributing

Saat menambah endpoint baru, pastikan untuk:
1. Menambahkan dokumentasi di `api-spec.md`
2. Menambahkan annotations di controller (untuk Scribe)
3. Update deployment guide jika ada perubahan infrastruktur

## 🆘 Support

Untuk pertanyaan atau masalah:
- Check [API Specification](./api-spec.md) untuk detail endpoint
- Check [Architecture](./architecture.md) untuk pemahaman sistem
- Check [Deployment Guide](./deployment.md) untuk masalah deployment








