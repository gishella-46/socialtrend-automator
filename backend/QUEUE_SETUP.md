# Laravel Queue & Scheduler Setup

## 📋 Fitur yang Ditambahkan

### 1. Laravel Queue dengan Redis ✅
- Konfigurasi queue menggunakan Redis sebagai default connection
- File: `config/queue.php`
- Connection: `redis` (default)
- Queue name: `uploads` (untuk upload jobs)

### 2. Command schedule:run ✅
- Command yang menjalankan scheduler setiap menit
- File: `app/Console/Commands/ScheduleRunCommand.php`
- Mencari scheduled posts yang sudah waktunya (`status='pending'` dan `scheduled_at <= now()`)
- Dispatch jobs ke Redis queue untuk diproses

### 3. Job DispatchUploadJob ✅
- Job untuk mengirim request ke Python FastAPI `/api/upload`
- File: `app/Jobs/DispatchUploadJob.php`
- Menggunakan queue connection: `redis`
- Queue name: `uploads`
- Payload yang dikirim:
  - `scheduled_post_id`
  - `user_id`
  - `social_account_id`
  - `content`
  - `media_urls`
  - `scheduled_at`
  - `callback_url` (untuk webhook)

### 4. Endpoint Webhook ✅
- Endpoint: `POST /api/upload/callback`
- File: `app/Http/Controllers/UploadWebhookController.php`
- Menerima callback dari Python FastAPI service
- Update status scheduled post berdasarkan hasil upload:
  - `status='posted'` jika sukses
  - `status='failed'` jika gagal

## 🚀 Setup & Usage

### 1. Pastikan Redis Running

```bash
docker-compose up -d redis
```

### 2. Setup Queue Worker

Jalankan queue worker untuk memproses jobs:

```bash
docker-compose exec backend php artisan queue:work redis --queue=uploads
```

Atau untuk development (auto-restart):

```bash
docker-compose exec backend php artisan queue:listen redis --queue=uploads
```

### 3. Setup Scheduler

Laravel scheduler perlu dijalankan setiap menit. Di production, tambahkan ke cron:

```bash
* * * * * cd /path-to-project && php artisan schedule:run >> /dev/null 2>&1
```

Di Docker, bisa ditambahkan ke docker-compose.yml atau jalankan secara manual:

```bash
# Run scheduler manually (akan check setiap menit)
docker-compose exec backend php artisan schedule:run
```

Atau setup cron di container:

```dockerfile
# Tambahkan ke Dockerfile
RUN echo "* * * * * php /var/www/html/artisan schedule:run >> /dev/null 2>&1" | crontab -
```

### 4. Environment Variables

Pastikan environment variables sudah di-set:

```env
QUEUE_CONNECTION=redis
REDIS_HOST=redis
REDIS_PORT=6379
AUTOMATION_SERVICE_URL=http://automation:5000
APP_URL=http://localhost
```

## 📊 Flow

1. **User membuat scheduled post** → `POST /api/schedule`
2. **Scheduler berjalan setiap menit** → `php artisan schedule:run`
3. **Scheduler menemukan posts yang ready** → Status `pending` dan `scheduled_at <= now()`
4. **Dispatch job ke Redis** → `DispatchUploadJob::dispatch($post)`
5. **Queue worker mengambil job** → `php artisan queue:work`
6. **Job mengirim request ke Python** → `POST http://automation:5000/api/upload`
7. **Python memproses upload** → Upload ke social media platform
8. **Python mengirim callback** → `POST http://backend/api/upload/callback`
9. **Backend update status** → `posted` atau `failed`

## 🔧 Testing

### Test Scheduler Command

```bash
docker-compose exec backend php artisan schedule:run
```

### Test Queue Worker

```bash
# Start queue worker
docker-compose exec backend php artisan queue:work redis --queue=uploads

# Di terminal lain, dispatch job manual
docker-compose exec backend php artisan tinker
>>> $post = App\Models\ScheduledPost::first();
>>> App\Jobs\DispatchUploadJob::dispatch($post);
```

### Test Webhook Endpoint

```bash
curl -X POST http://localhost/api/upload/callback \
  -H "Content-Type: application/json" \
  -d '{
    "scheduled_post_id": 1,
    "status": "posted",
    "message": "Post uploaded successfully",
    "post_url": "https://instagram.com/p/abc123"
  }'
```

## 📝 Notes

- **Queue Connection**: Default menggunakan `redis`
- **Queue Name**: Jobs dikirim ke queue `uploads`
- **Failed Jobs**: Tersimpan di table `failed_jobs` (jika ada error)
- **Scheduler**: Harus dijalankan setiap menit (cron atau manual)
- **Queue Worker**: Harus running untuk memproses jobs dari Redis
- **Webhook**: Tidak memerlukan authentication (dipanggil dari internal service)

## 🐛 Troubleshooting

### Queue tidak diproses
- Pastikan queue worker running: `php artisan queue:work`
- Check Redis connection: `php artisan tinker` → `Redis::ping()`

### Scheduler tidak jalan
- Pastikan command ada di `routes/console.php`
- Jalankan manual: `php artisan schedule:run`
- Check logs: `storage/logs/laravel.log`

### Webhook tidak terpanggil
- Check Python service bisa akses backend URL
- Pastikan `callback_url` di payload benar
- Check CORS jika diperlukan


















