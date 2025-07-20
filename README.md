XrayR-Mikrotik 🛡️
XrayR-Mikrotik ابزاری است برای ساخت و راه‌اندازی یک کانتینر کاملاً سازگار از XrayR بر روی RouterOS میکروتیک با استفاده از قابلیت Container در MikroTik.

❓ این ابزار چیست؟
وقتی نسخه اصلی Docker از XrayR را روی میکروتیک اجرا می‌کنید، معمولاً با مشکلاتی مواجه می‌شوید مثل:

فایل پیکربندی config.yml بارگذاری نمی‌شود

کانتینر کرش می‌کند و متوقف می‌شود

XrayR-Mikrotik این مشکلات را حل می‌کند و یک کانتینر آماده با .tar می‌سازد که:

✅ پیکربندی شما را به‌درستی بارگذاری می‌کند
✅ بدون خطا در RouterOS میکروتیک اجرا می‌شود
✅ به صورت .tar قابل ایمپورت مستقیم در کانتینر میکروتیک است

🛠 امکانات
ویرایش سریع config.yml

ساخت ایمیج Docker شخصی‌سازی‌شده

خروجی گرفتن به فرمت .tar

اجرای فایل‌سرور موقت برای دریافت ایمیج از میکروتیک

سازگار با سیستم کانتینر میکروتیک

🚀 مراحل سریع نصب (لینوکس)
در ترمینال لینوکس خود اجرا کنید:

bash
Copy
Edit
wget https://raw.githubusercontent.com/SudoMds/XrayR-Mikrotik/refs/heads/main/XMikro.sh
chmod +x XMikro.sh
bash XMikro.sh
سپس مراحل اسکریپت را دنبال کنید.

⚠️ اگر فایل‌سرور موقت را فعال کردید، حتماً در پایان از طریق منوی اسکریپت آن را متوقف کنید.

🔧 این اسکریپت چه کاری انجام می‌دهد؟
کلون کردن پروژه XrayR از گیت‌هاب

دانلود Dockerfile آماده

ویرایش فایل config.yml

ساخت ایمیج Docker

خروجی گرفتن به فرمت .tar

(اختیاری) اجرای فایل‌سرور برای دریافت فایل

(مهم) توقف فایل‌سرور پس از اتمام

📦 آموزش تنظیم کانتینر در MikroTik
مرحله ۱: تنظیمات شبکه (از طریق ترمینال)
/interface bridge add name=docker comment="Docker Container Bridge"
/ip address add address=172.0.0.1/24 interface=docker comment="Docker Bridge IP"
/interface veth add name=veth-docker address=172.0.0.2/24 gateway=172.0.0.1 comment="Container Virtual NIC"
/interface bridge port add bridge=docker interface=veth-docker
/ip firewall nat add chain=srcnat out-interface=docker action=masquerade comment="NAT for Containers"

مرحله ۲: آپلود فایل کانتینر
فایل .tar ساخته‌شده را از سرور لینوکس دانلود کنید

آن را با Winbox یا SCP در مسیر /container/xrayr آپلود کنید

مرحله ۳: ساخت کانتینر در Winbox
به مسیر System > Container بروید

روی دکمه + کلیک کنید

تنظیمات نمونه:

تنظیم	مقدار
File	xrayr-xxxx.tar
Root Dir	/container/xrayr
Interface	veth-docker
DNS	1.1.1.1, 8.8.8.8
Start on Boot	✔️

سپس روی کانتینر راست کلیک کرده و گزینه Start را بزنید

✅ مطمئن شوید وضعیت کانتینر "running" باشد

🧠 توسعه‌دهنده
ساخته‌شده با ❤️ توسط @SudoMds

