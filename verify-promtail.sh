#!/bin/bash

# سكريبت التحقق من عمل Promtail وتدفق اللوجات

echo "======================================"
echo "فحص Promtail والاتصال بـ Loki"
echo "======================================"

echo ""
echo "1️⃣ التحقق من حالة خدمة Promtail..."
systemctl status promtail --no-pager | head -15

echo ""
echo "2️⃣ التحقق من أن Promtail يعمل..."
if curl -s http://localhost:9080/ready | grep -q "ready"; then
    echo "✅ Promtail يعمل بشكل صحيح"
else
    echo "❌ Promtail لا يستجيب"
fi

echo ""
echo "3️⃣ عرض آخر 20 سطر من لوجات Promtail..."
journalctl -u promtail -n 20 --no-pager

echo ""
echo "4️⃣ التحقق من ملفات اللوجات التي يقرأها Promtail..."
if [ -f /var/lib/promtail/positions.yaml ]; then
    echo "✅ ملف Positions موجود:"
    cat /var/lib/promtail/positions.yaml
else
    echo "⚠️  ملف Positions غير موجود بعد"
fi

echo ""
echo "5️⃣ التحقق من وجود لوجات PM2..."
PM2_LOGS_DIR="/home/ubuntu/.pm2/logs"
if [ -d "$PM2_LOGS_DIR" ]; then
    echo "✅ مجلد لوجات PM2 موجود:"
    ls -lh $PM2_LOGS_DIR/*.log 2>/dev/null || echo "⚠️  لا توجد ملفات لوج"
else
    echo "❌ مجلد لوجات PM2 غير موجود في $PM2_LOGS_DIR"
    echo "   جرب: pm2 list للتحقق من مسار اللوجات"
fi

echo ""
echo "6️⃣ عرض Metrics من Promtail..."
echo "عدد الملفات المراقبة:"
curl -s http://localhost:9080/metrics | grep "promtail_files_active_total" || echo "لا توجد ملفات مراقبة بعد"

echo ""
echo "عدد السطور المرسلة:"
curl -s http://localhost:9080/metrics | grep "promtail_sent_entries_total" || echo "لم يتم إرسال سطور بعد"

echo ""
echo "======================================"
echo "الخطوات التالية:"
echo "======================================"
echo "1. إذا كانت الخدمة تعمل، افتح Grafana"
echo "2. اذهب إلى Explore واختر Loki"
echo "3. استعلم: {job=\"strapi\"}"
echo "4. إذا لم تظهر نتائج، تحقق من:"
echo "   - Loki endpoint في /etc/promtail/config.yml"
echo "   - مسار لوجات PM2 صحيح"
echo "   - Firewall يسمح بالاتصال"
echo ""
