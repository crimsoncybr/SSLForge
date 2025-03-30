# 🔐 SSLForge

**SSLForge** is a fully interactive Bash script that automates the configuration of an Apache HTTPS server using a self-signed SSL certificate.  
Built with clean logging — it's perfect for personal labs, internal servers, or testing environments.

---

## 🚀 Features

- 🧰 Starts and enables the Apache web server
- 📄 Deploys your own `index.html` landing page
- 🔐 Generates a custom self-signed SSL certificate
- 🧾 Applies your SSL certificate to a secure virtual host
- 🤖 Built for Red Teamers, students, and home-labbers

---

## 📁 Project Structure

```
SSLForge/
├── SSLForge.sh                  # The main script
├── README.md                    # This file
└── files/
    ├── index.html               # Your custom landing page
    └── https-selfsigned.conf    # Apache SSL site config
```

---

## 🛠️ Prerequisites

- A Linux system (tested on Kali / Ubuntu)
- `apache2` installed (script installs it if missing)
- Root privileges (`sudo ./SSLForge.sh`)
- The following files in a `files/` directory:
  - `index.html`
  - `https-selfsigned.conf`

---

## 📦 How to Use

```bash
https://github.com/crimsoncybr/SSLForge.git
cd SSLForge
chmod +x SSLForge.sh
sudo ./SSLForge.sh
```

During execution, you'll be prompted to enter:
- Country code, State, City, Organization
- Common Name (domain or IP)
- Email address
- Target Server IP

Once complete, SSLForge will:
- Copy your web page to `/var/www/html`
- Generate your SSL cert in `/etc/apache2/ssl/`
- Enable the Apache SSL site
- Reload Apache
- Run a configuration test

---

## 🔎 Example Output

```
[INFO] Starting and enabling Apache service...
[OK]   Apache is running (status: active)
🔐 [INPUT] Enter SSL Certificate Details:
...
[OK]   SSL certificate created at /etc/apache2/ssl
[OK]   SSL site enabled and Apache reloaded.
[OK]   Apache server configured correctly.

✅ Script completed successfully! Your HTTPS site should now be live.
```
![Screenshot 2025-03-30 214553](https://github.com/user-attachments/assets/a33b4cba-3377-467d-a95c-a4064b902653)

---

## ⚠️ Notes

- This script uses a **self-signed certificate** — ideal for test labs or internal use
- For public production, consider using **Let’s Encrypt** (not included)
- Designed for **learning, red team practice, and automation demos**

---

## 👨‍💻 Author

**Dean Cohen**  
✈️ Cybersecurity Enthusiast  
🛡️ Red Team | Web Attacks | Scripting  
🔧 Built this to combine my love for automation & offensive security

---

## 📜 License

This project is licensed under the MIT License — do whatever you want, just give credit.

---

## ✨ Stay Secure. Stay Curious.
