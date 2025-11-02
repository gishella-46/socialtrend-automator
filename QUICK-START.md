# 🚀 Quick Start Guide

## ⚡ One-Click Access

**Double-click the files below to control your application:**

### 📂 Main Controls

| File | Action | Description |
|------|--------|-------------|
| **START.bat** | ▶️ Start | Start all services (Laravel, FastAPI, Frontend, DB) |
| **STOP.bat** | ⏹️ Stop | Stop all running services |
| **RESTART.bat** | 🔄 Restart | Restart all services |
| **STATUS.bat** | 📊 Status | Check which services are running |

### 📂 Additional Tools

| File | Action | Description |
|------|--------|-------------|
| **OPEN-WEBSITE.bat** | 🌐 Open | Open any service in browser (Frontend, API, Docs, etc.) |
| **VIEW-LOGS.bat** | 📋 Logs | View logs from any service |

---

## 🎯 Quick Access URLs

After starting, access your application at:

- **Frontend**: http://localhost
- **Backend API**: http://localhost/api
- **Laravel Docs**: http://localhost/docs
- **FastAPI Docs**: http://localhost/automation/docs
- **FastAPI ReDoc**: http://localhost/automation/redoc
- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Kibana**: http://localhost:5601

---

## 💡 Tips

1. **First Time Setup**: 
   - Ensure Docker Desktop is installed and running
   - Double-click `START.bat` to build and start everything

2. **Daily Use**:
   - Double-click `START.bat` to start
   - Double-click `OPEN-WEBSITE.bat` to open in browser
   - Double-click `STATUS.bat` to check if running

3. **Troubleshooting**:
   - Double-click `VIEW-LOGS.bat` to see what's happening
   - Double-click `RESTART.bat` if something isn't working

---

## ❓ Common Issues

**Q: "Docker is not running"**
- Solution: Open Docker Desktop and wait for it to start

**Q: "Cannot connect to localhost"**
- Solution: Double-click `STATUS.bat` to check if services are running
- If not, double-click `START.bat`

**Q: "Port already in use"**
- Solution: Double-click `STOP.bat`, then `START.bat`

---

## 🔧 Advanced

For advanced operations, see the main [README.md](README.md).

