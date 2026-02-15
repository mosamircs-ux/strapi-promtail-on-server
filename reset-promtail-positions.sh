#!/bin/bash

# سكريبت لإعادة تعيين Promtail لقراءة كل اللوجات من البداية

echo "======================================"
echo "إعادة تعيين Promtail لقراءة كل اللوجات"
echo "======================================"

echo ""
echo "1️⃣ إيقاف خدمة Promtail..."
sudo systemctl stop promtail

echo ""
echo "2️⃣ حذف ملف Positions (لإعادة القراءة من البداية)..."
if [ -f /var/lib/promtail/positions.yaml ]; then
    sudo rm /var/lib/promtail/positions.yaml
    echo "✅ تم حذف ملف positions"
else
    echo "⚠️  ملف positions غير موجود"
fi

echo ""
echo "3️⃣ إعادة تشغيل Promtail..."
sudo systemctl start promtail

echo ""
echo "4️⃣ التحقق من الحالة..."
sudo systemctl status promtail --no-pager | head -15

echo ""
echo "======================================"
echo "✅ تم إعادة التعيين بنجاح!"
echo "======================================"
echo ""
echo "Promtail الآن سيقرأ كل اللوجات من البداية."
echo "قد يستغرق بعض الوقت لإرسال كل اللوجات إلى Loki."
echo ""
echo "للمتابعة:"
echo "  sudo journalctl -u promtail -f"
echo ""
