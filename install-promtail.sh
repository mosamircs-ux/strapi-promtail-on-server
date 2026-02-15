#!/bin/bash

# سكريبت تثبيت Promtail على EC2
# يجب تشغيله بصلاحيات sudo

set -e

echo "======================================"
echo "تثبيت Promtail على EC2"
echo "======================================"

# المتغيرات - عدّلها حسب احتياجك
PROMTAIL_VERSION="2.9.3"
LOKI_ENDPOINT="https://t80ossw0ccs44ogwcokwg0oc.coolify.mhg-int.com"
PM2_LOGS_PATH="/home/ubuntu/.pm2/logs"  # عدّل حسب مسار PM2 لديك

# التحقق من صلاحيات sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ يرجى تشغيل السكريبت بصلاحيات sudo"
    exit 1
fi

echo ""
echo "📥 الخطوة 1: تحميل Promtail..."
cd /tmp
wget "https://github.com/grafana/loki/releases/download/v${PROMTAIL_VERSION}/promtail-linux-amd64.zip"
unzip -o promtail-linux-amd64.zip

echo ""
echo "📦 الخطوة 2: تثبيت Promtail..."
mv promtail-linux-amd64 /usr/local/bin/promtail
chmod +x /usr/local/bin/promtail

echo ""
echo "✅ تم تثبيت Promtail بنجاح!"
promtail --version

echo ""
echo "📁 الخطوة 3: إنشاء المجلدات..."
mkdir -p /etc/promtail
mkdir -p /var/lib/promtail

echo ""
echo "⚙️  الخطوة 4: إنشاء ملف التكوين..."
cat > /etc/promtail/config.yml <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: ${LOKI_ENDPOINT}/loki/api/v1/push

scrape_configs:
  - job_name: strapi-pm2
    static_configs:
      - targets:
          - localhost
        labels:
          job: strapi
          environment: production
          host: \${HOSTNAME}
          __path__: ${PM2_LOGS_PATH}/*.log
    
    pipeline_stages:
      - regex:
          expression: '^(?P<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z)'
      - timestamp:
          source: timestamp
          format: RFC3339Nano
      - regex:
          expression: '\[(?P<level>\w+)\]'
      - labels:
          level:
      - regex:
          expression: '\/\.pm2\/logs\/(?P<app_name>[^-]+)'
      - labels:
          app_name:
EOF

echo ""
echo "🔧 الخطوة 5: إنشاء Systemd Service..."
cat > /etc/systemd/system/promtail.service <<EOF
[Unit]
Description=Promtail service for log collection
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/config.yml
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "🚀 الخطوة 6: تفعيل وتشغيل الخدمة..."
systemctl daemon-reload
systemctl enable promtail
systemctl start promtail

echo ""
echo "======================================"
echo "✅ تم التثبيت بنجاح!"
echo "======================================"
echo ""
echo "📊 حالة الخدمة:"
systemctl status promtail --no-pager

echo ""
echo "======================================"
echo "الخطوات التالية:"
echo "======================================"
echo "1. تحقق من اللوجات: sudo journalctl -u promtail -f"
echo "2. تحقق من الاتصال: curl http://localhost:9080/ready"
echo "3. افتح Grafana واذهب إلى Explore"
echo "4. اختر Loki واستعلم: {job=\"strapi\"}"
echo ""
