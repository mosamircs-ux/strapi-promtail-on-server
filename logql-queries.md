# أمثلة على LogQL Queries لـ Strapi

## Queries أساسية

### عرض جميع لوجات Strapi
```logql
{job="strapi"}
```

### عرض الأخطاء فقط
```logql
{job="strapi", level="error"}
```

### عرض Warnings
```logql
{job="strapi", level="warn"}
```

### البحث في محتوى اللوجات
```logql
{job="strapi"} |= "database"
```

### استبعاد لوجات معينة
```logql
{job="strapi"} != "health check"
```

---

## Queries متقدمة

### عد الأخطاء في آخر 5 دقائق
```logql
count_over_time({job="strapi", level="error"}[5m])
```

### معدل الأخطاء في الثانية
```logql
rate({job="strapi", level="error"}[1m])
```

### البحث بـ Regex
```logql
{job="strapi"} |~ "(?i)(error|exception|failed)"
```

### أخطاء Database
```logql
{job="strapi"} |~ "(?i)(database|connection|query).*error"
```

### استخراج وتحليل JSON
```logql
{job="strapi"} | json | level="error"
```

### فلترة حسب Response Time
```logql
{job="strapi"} |~ "took \\d+ms" | regexp "took (?P<duration>\\d+)ms" | duration > 1000
```

---

## Queries للـ Alerts

### معدل أخطاء عالي (أكثر من 10 في 5 دقائق)
```logql
count_over_time({job="strapi", level="error"}[5m]) > 10
```

### عدم وجود لوجات (التطبيق متوقف)
```logql
absent_over_time({job="strapi"}[5m]) == 1
```

### أخطاء متكررة من نفس النوع
```logql
sum by (error_type) (count_over_time({job="strapi"} |~ "Error: (?P<error_type>.*)" [5m])) > 5
```

### استجابة بطيئة
```logql
avg_over_time({job="strapi"} | regexp "took (?P<duration>\\d+)ms" | unwrap duration [5m]) > 1000
```

---

## Queries للـ Dashboard Panels

### إجمالي اللوجات (Time Series)
```logql
sum(count_over_time({job="strapi"}[1m]))
```

### توزيع اللوجات حسب المستوى (Pie Chart)
```logql
sum by (level) (count_over_time({job="strapi"}[5m]))
```

### Top 10 Error Messages (Table)
```logql
topk(10, sum by (msg) (count_over_time({job="strapi", level="error"} | json | __error__="" [1h])))
```

### Logs per Application (Bar Chart)
```logql
sum by (app_name) (count_over_time({job="strapi"}[5m]))
```

### Error Rate Trend (Graph)
```logql
sum(rate({job="strapi", level="error"}[5m]))
```

---

## Queries للتحليل

### أكثر 5 endpoints تسبب أخطاء
```logql
topk(5, sum by (path) (count_over_time({job="strapi"} | json | level="error" | __error__="" [1h])))
```

### متوسط Response Time
```logql
avg_over_time({job="strapi"} | regexp "took (?P<duration>\\d+)ms" | unwrap duration [5m])
```

### عدد الطلبات حسب HTTP Method
```logql
sum by (method) (count_over_time({job="strapi"} | json | __error__="" [5m]))
```

### أخطاء 500 في آخر ساعة
```logql
count_over_time({job="strapi"} |~ "status.*5\\d{2}" [1h])
```

---

## نصائح للاستخدام

1. **استخدم Time Range بحكمة**: Queries على فترات طويلة قد تكون بطيئة
2. **Filter مبكراً**: استخدم labels في البداية `{job="strapi"}` قبل regex
3. **استخدم `__error__=""`**: لتجنب الأخطاء في parsing
4. **Test في Explore أولاً**: قبل إضافة Query للـ Dashboard أو Alert
