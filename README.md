# نصب خودکار Passwall2 و AmneziaWG بر روی OpenWrt

این پروژه یک اسکریپت ساده برای نصب ابزارهای **Passwall2** و **AmneziaWG** روی سیستم‌عامل OpenWrt است.

⚠️ **نکته مهم**: این اسکریپت برای روترهایی طراحی شده که OpenWrt نسخه `23.05.6` یا `24.10.2` روی آن‌ها نصب شده است. اگر نسخه قدیمی‌تری دارید، ابتدا روتر خود را به‌روزرسانی کنید.

---

## پیش‌نیازها

* روتر شما باید **OpenWrt 23.05.6 یا بالاتر** داشته باشد.
  (برای چک کردن: دستور زیر را در ترمینال روتر اجرا کنید:)

  ```sh
  cat /etc/openwrt_release
  ```
* دسترسی روتر به اینترنت.
* دسترسی SSH به روتر.

📌 اگر روتر شما از نسخه قدیمی OpenWRT استفاده میکند ، از **[Firmware Selector OpenWrt](https://firmware-selector.openwrt.org/)** برای به‌روزرسانی استفاده کنید.
بسته‌های زیر را مانند تصویر زیر در انتهای بسته های لیست شده در installed packages وارد کنید :
`coreutils coreutils-base64 coreutils-nohup curl ip-full kmod-nft-socket kmod-nft-tproxy libc libuci-lua lua luci-compat luci-lib-jsonc luci-lua-runtime resolveip unzip v2ray-geoip v2ray-geosite v2ray-geosite-ir wget-ssl kmod-inet-diag kmod-netlink-diag kmod-tun dnsmasq-full`
پیشنهاد میشود برای جلوگیری از تداخل آی پی در شبکه رنج پیشفرض ۱.۱ را نیز تغییر دهید. 

<img width="1060" height="919" alt="image" src="https://github.com/user-attachments/assets/ce880844-5d9a-48e4-815c-c6cd01490ec7" />


---

## نحوه استفاده از برنامه

### ۱. دانلود اسکریپت

```sh
cd /tmp/
wget https://raw.githubusercontent.com/iranopenwrt/auto/main/install.sh
chmod +x install.sh
```

### ۲. اجرای اسکریپت

```sh
./install.sh
```

* ابتدا چک‌های پیش‌نیاز (اینترنت، DNS، اتصال به GitHub) انجام می‌شود. در صورت مواجه شدن با خطا در هر یک از پیشنیازها لازم است نسبت به رفع ایراد اقدام گردد.  
* در صورت چک شدن پیشنیازها از شما پرسیده می‌شود که آیا Passwall2 یا AmneziaWG را نصب کنید (پاسخ با `y/n`).

---

## گزینه‌های اختیاری (اجرای خودکار بدون پرسش)

* `--passwall2`: نصب Passwall2 بدون پرسش.
* `--ir`: فعال‌سازی لیست‌های جغرافیایی ایرانی (توصیه برای کاربران ایرانی).
* `--tcp-all`: هدایت تمام ترافیک TCP (پورت‌های 1 تا 65535) از طریق پروکسی.
* `--amneziawg`: نصب AmneziaWG بدون پرسش.

### مثال:
نصب پسوال ۲ بهمراه لیست وبسایتها و آدرسهای آیپی ایران 
```sh
cd /tmp/ && wget https://raw.githubusercontent.com/iranopenwrt/auto/main/install.sh && sh install.sh --passwall2 --ir --tcp-all
```
نصب پسوال۲ بهمراه لیست وبسایتها و آدرسهای آیپی ایران و AmneziaWG

```sh
cd /tmp/ && wget https://raw.githubusercontent.com/iranopenwrt/auto/main/install.sh && sh install.sh --passwall2 --ir --tcp-all --amneziawg
```
---

## پس از نصب

* به رابط وب **LuCI** بروید (معمولاً در `192.168.1.1`).
* در بخش **Services > Passwall2** یا **AmneziaWG**، تنظیمات خود را پیکربندی کنید.
* در صورت نیاز، روتر را ری‌استارت کنید:

  ```sh
  reboot
  ```

---

## خروجی اسکریپت و رفع مشکلات

اسکریپت خروجی‌های رنگی و واضحی تولید می‌کند:

* `[INFO]` (آبی): اطلاعات معمولی، مشکلی نیست.
* `[SUCCESS]` (سبز): موفقیت در عملیات.
* `[WARNING]` (زرد): هشدار (مثلاً نسخه OpenWrt قدیمی است).
* `[ERROR]` (قرمز): خطا (اسکریپت متوقف می‌شود).

### خطاهای رایج و راه‌حل‌ها:

* **No internet connectivity** → بررسی اتصال اینترنت (`ping 8.8.8.8`).
* **DNS resolution failed** → بررسی عملکرد دی ان اس در لوسی.
* **GitHub connectivity failed** → ایراد دسترسی به گیتهاب؛ .
* **Failed to access package** → ایراد دسترسی به رپوها

---

## نمونه خروجی موفق

```text
[INFO] Starting pre-installation checks...
[INFO] Checking internet connectivity by pinging 8.8.8.8...
PING 8.8.8.8 (8.8.8.8): 56 data bytes
...
[SUCCESS] Internet connectivity test passed.
...
[SUCCESS] All requested installations completed.
```

---

## محدودیت‌ها و نکات

* این اسکریپت فقط روی **OpenWrt** کار می‌کند (نه روی فریم‌ور اصلی روترهای کارخانه‌ای).
* بعد از نصب، حتماً برای امنیت پسورد قوی تنظیم کنید.
* مطمئن شوید محدوده آی پی روتر OpenWRT با مودم متصل به آن **متفاوت** باشد

---

## لایسنس

این پروژه تحت لایسنس **GNU General Public License v2** منتشر شده است.
جزئیات در فایل‌های اسکریپت موجود است.

---

اگر مشکلی داشتید، لطفاً در بخش **Issues** این ریپو گزارش دهید.
موفق باشید! 🚀
