# Server Setup Guide untuk SocialTrend Automator

## Cara Mendapatkan IP Address Server

### Scenario 1: Server Sudah Ada

Jika Anda sudah punya server (VPS, dedicated, cloud instance), berikut cara mendapatkan IP-nya:

#### A. Dari Panel Hosting/VPS
- **DigitalOcean**: Dashboard → Droplets → Lihat IP Address
- **AWS EC2**: EC2 Console → Instances → Public IPv4 address
- **Linode**: Linodes → Pilih Linode → Networking → IPv4 Address
- **Vultr**: Servers → Pilih Server → Detail → Public IP
- **Google Cloud**: Compute Engine → VM instances → External IP
- **Azure**: Virtual Machines → Pilih VM → Overview → Public IP address

#### B. Dari Command Line (SSH ke Server)
Jika sudah punya akses SSH ke server:
```bash
# Login ke server
ssh username@your-server.com

# Cek Public IP
curl ifconfig.me
# atau
curl ipinfo.io/ip
# atau
hostname -I
```

### Scenario 2: Belum Punya Server? Pilih Provider

#### Recommended: DigitalOcean (Mudah & Murah)
**Keuntungan:**
- Interface sederhana
- Dokumentasi lengkap
- Pricing transparan
- Community besar

**Setup Droplet:**
1. Daftar: https://www.digitalocean.com/
2. Create Droplet:
   - Choose an image: **Ubuntu 22.04 LTS**
   - Plan: **Basic** → **$6/month** (1 GB RAM, 25 GB SSD) sudah cukup untuk testing
   - Datacenter: Pilih yang dekat (Singapore, Amsterdam, dll)
   - Authentication: **SSH keys** (lebih aman) atau **Password**
3. Klik "Create Droplet"
4. **IP Address akan muncul di dashboard!**

**Get IP:** Dashboard → Droplets → Lihat "Public IPv4" (format: xxx.xxx.xxx.xxx)

**Setup First Time:**
```bash
# Login via SSH
ssh root@YOUR_IP_ADDRESS

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version
```

#### Alternative: AWS EC2 (Free Tier Available)
**Free Tier:** 1 year free (750 hours/month)

**Setup Instance:**
1. Daftar: https://aws.amazon.com/
2. EC2 → Launch Instance:
   - Name: `socialtrend-prod`
   - AMI: **Ubuntu Server 22.04 LTS**
   - Instance type: **t2.micro** (free tier eligible)
   - Key pair: Create new atau choose existing
   - Network settings: Enable "Auto-assign Public IP"
   - Storage: 20 GB (default)
3. Launch Instance
4. **Public IPv4 Address** akan muncul di EC2 console

#### Alternative: Linode (Simple & Affordable)
**Pricing:** Starting at $5/month

**Setup:**
1. Daftar: https://www.linode.com/
2. Create → Linode:
   - Image: **Ubuntu 22.04 LTS**
   - Region: Pilih terdekat
   - Plan: **Nanode 1 GB** ($5/month) - cukup untuk testing
   - Root Password: Set password
3. Create Linode
4. **IP Address** muncul di dashboard

#### Alternative: Vultr (Global Coverage)
**Pricing:** Starting at $2.50/month

**Setup:**
1. Daftar: https://www.vultr.com/
2. Products → Deploy Server:
   - Server: **Regular Cloud**
   - Location: Pilih terdekat
   - OS: **Ubuntu 22.04 LTS**
   - Server Plan: **Regular Performance** → **$6/month** (1 vCPU, 1 GB RAM)
   - Additional Features: Enable IPv6 (optional)
3. Deploy Now
4. **IP Address** muncul di Products page

### Scenario 3: Gunakan Domain (Jika Sudah Punya)

Jika Anda sudah punya domain (misal: `yourdomain.com`):
- DNS Records sudah dikonfigurasi
- IP akan otomatis ter-resolve
- Gunakan domain name untuk SSH_HOST

**Setup Domain → IP:**
```bash
# A Record di DNS provider Anda:
yourdomain.com     A      YOUR_IP_ADDRESS
www.yourdomain.com A      YOUR_IP_ADDRESS
```

### Checklist Setup Server

#### Minimal Requirements:
- **OS**: Ubuntu 22.04 LTS atau 20.04 LTS
- **RAM**: Minimum 1 GB (2 GB recommended)
- **Storage**: Minimum 20 GB SSD
- **CPU**: 1 vCPU (2+ recommended)
- **Network**: Public IP address

#### Software yang Diperlukan:
```bash
# Install semua via root
apt update && apt upgrade -y

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Git
apt install git -y

# Optional: UFW firewall
apt install ufw -y
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable

# Verify
docker --version
docker-compose --version
git --version
```

### Setup SSH Access (Untuk GitHub Actions)

#### Option 1: Generate SSH Key Pair (Recommended)

**Lokal (Windows):**
```powershell
# Generate key pair
ssh-keygen -t rsa -b 4096 -C "deploy@socialtrend-automator"

# Copy public key
cat ~/.ssh/id_rsa.pub

# Save private key untuk GitHub secret
cat ~/.ssh/id_rsa
```

**Server:**
```bash
# Add public key ke authorized_keys
mkdir -p ~/.ssh
echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**GitHub Secret:**
- Name: `SSH_PRIVATE_KEY`
- Value: Paste seluruh isi dari `id_rsa` (termasuk ---BEGIN dan ---END lines)

#### Option 2: Password Authentication (Less Secure)

```bash
# On server
passwd  # Set root password

# Test connection
ssh root@YOUR_IP_ADDRESS
```

### Deployment Path

Setelah clone repository, catat path deployment Anda:

```bash
# Clone repository
cd /home
git clone https://github.com/gishella-46/socialtrend-automator.git
cd socialtrend-automator

# Path: /home/socialtrend-automator

# Update workflow dengan path ini!
```

**Update `.github/workflows/main.yml`:**
```yaml
script: |
  cd /home/socialtrend-automator  # ← Ganti dengan path Anda
  docker-compose pull
  docker-compose up -d --build
  docker-compose restart
```

### Testing SSH Connection

Before configuring GitHub secrets, test connection:

```bash
# Test SSH
ssh -i ~/.ssh/id_rsa root@YOUR_IP_ADDRESS

# Test Docker
docker ps

# Test Docker Compose
docker-compose --version
```

### Final Configuration

#### 1. GitHub Secrets:
- `SSH_HOST`: Your IP address (e.g., `157.245.123.45`)
- `SSH_USERNAME`: Server username (e.g., `root`, `ubuntu`)
- `SSH_PRIVATE_KEY`: Full private key content
- `SSH_PORT`: `22`

#### 2. Update Workflow Path:
Edit `.github/workflows/main.yml` line 324:
```yaml
cd /home/socialtrend-automator  # Your actual path
```

#### 3. Environment Variables:
On your server, create `.env` files:
```bash
# Backend
nano backend/.env
# Automation
nano automation/.env
# Frontend
nano frontend/.env
```

#### 4. First Deployment:
```bash
# Generate Laravel key
docker-compose run --rm backend php artisan key:generate

# Run migrations
docker-compose exec backend php artisan migrate --force

# Generate docs
docker-compose exec backend php artisan scribe:generate
```

### Server Monitoring

Setelah deploy, monitor server:

```bash
# Container status
docker-compose ps

# Logs
docker-compose logs -f

# Resources
htop
df -h  # Disk usage
free -m  # Memory usage
```

### Troubleshooting

#### Can't SSH to server
```bash
# Check firewall
ufw status
ufw allow 22/tcp
ufw reload

# Check SSH service
systemctl status ssh
sudo systemctl restart ssh
```

#### Docker permission issues
```bash
# Add user to docker group
usermod -aG docker $USER
newgrp docker

# Or run as root
sudo docker ps
```

#### Low disk space
```bash
# Clean Docker
docker system prune -a
docker volume prune

# Check usage
df -h
du -sh /var/lib/docker
```

### Recommended Providers Comparison

| Provider | Price/Month | RAM | Storage | CPU | Best For |
|----------|-------------|-----|---------|-----|----------|
| **DigitalOcean** | $6 | 1 GB | 25 GB | 1 vCPU | **Recommended** |
| AWS EC2 | Free (1yr) | 1 GB | 20 GB | 1 vCPU | Learning |
| Linode | $5 | 1 GB | 25 GB | 1 vCPU | Budget |
| Vultr | $6 | 1 GB | 25 GB | 1 vCPU | Global |
| Hetzner | $4 | 4 GB | 40 GB | 2 vCPU | Best Value |

**Best Value:** Hetzner (Germany/Finland datacenters)
- Amazing specs untuk harga murah
- Perfekt untuk production

### Additional Resources

- [DigitalOcean Droplet Setup](https://docs.digitalocean.com/products/droplets/how-to/create/)
- [AWS EC2 Launch Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html)
- [Docker Installation](https://docs.docker.com/engine/install/)
- [Docker Compose Install](https://docs.docker.com/compose/install/)

### Support

Jika butuh bantuan:
1. Check server logs: `docker-compose logs`
2. Check GitHub Actions logs
3. Review this guide
4. Contact provider support
