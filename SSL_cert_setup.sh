#!/bin/bash

# === TEXT COLORS ===
# Regular text colors
BLACK="\033[0;30m"; RED="\033[0;31m"; GREEN="\033[0;32m"
YELLOW="\033[0;33m"; BLUE="\033[0;34m"; MAGENTA="\033[0;35m"
CYAN="\033[0;36m"; WHITE="\033[0;37m"

# Bold text versions
BOLD_BLACK="\033[1;30m"; BOLD_RED="\033[1;31m"; BOLD_GREEN="\033[1;32m"
BOLD_YELLOW="\033[1;33m"; BOLD_BLUE="\033[1;34m"; BOLD_MAGENTA="\033[1;35m"
BOLD_CYAN="\033[1;36m"; BOLD_WHITE="\033[1;37m"

# Reset to default
RESET="\033[0m"

# Clear the terminal for a clean display
clear

# === HEADER ===
# Displays a stylish script header
function HEADER() 
{
	echo -e "\033[1;31m\033[46m"
	echo "╔═══════════════════════════════════════════════╗"
	echo "║       🖥️ HTTPS Apache Server Setup Tool 🧰     ║"
	echo "║═══════════════════════════════════════════════║"
	echo "║                🤖Dean Cohen🤖                 ║"
	echo "║═══════════════════════════════════════════════║"
	echo "║          🚀 RTX - Red Team eXpert🔧           ║"
	echo "╚═══════════════════════════════════════════════╝"
	echo -e "\033[0m"
}

# === LOGGING HELPERS ===
# Functions for styled output messages
log_info() { echo -e "${BOLD_BLUE}[INFO] ${BLUE}$1${RESET}"; }
log_ok()   { echo -e "${BOLD_GREEN}[OK]  ${GREEN}$1${RESET}"; }
log_err()  { echo -e "${BOLD_RED}[ERROR] ${RED}$1${RESET}"; }

# === ROOT CHECK ===
# Makes sure the script is run with root permissions
if [ "$(whoami)" != "root" ]; then
	log_err "This script must be run as root."
	exit 1
else
	log_info "Running as root... ✅"
fi

# === UPDATE FUNCTION ===
# Optionally updates and installs Apache
function UPDATE() 
{
	log_info "Checking for updates..."
	apt-get update -qq && apt-get upgrade -y -qq

	log_info "Installing Apache (if not already installed)..."
	apt-get install apache2 -y -qq

	log_ok "System updated and Apache installed."
}

# === START & ENABLE APACHE ===
function APACHE_TEST() 
{
	log_info "Starting and enabling Apache service..."
	systemctl start apache2 &>/dev/null
	systemctl enable apache2 &>/dev/null

	ACTIVE=$(systemctl is-active apache2)
	log_ok "Apache is running (status: $ACTIVE)"
}

# === COPY FILES & ENABLE SSL MODULE ===
function RUN() 
{
	log_info "Copying HTML file to web root..."

	if [[ ! -f files/index.html ]]; then
		log_err "Missing: files/index.html"
		exit 1
	fi

	cp files/index.html /var/www/html/index.html
	a2enmod ssl &>/dev/null

	log_ok "index.html copied and SSL module enabled."
}

# === GET USER INPUT FOR SSL CERT ===
function INPUT() 
{
	echo -e "\n\033[1;34m🔐 [INPUT] Enter SSL Certificate Details: 🔐\033[0m"
	echo -e "\033[0;36m---------------------------------------------\033[0m"

	read -p $'\033[1;33m Country code (e.g. IL): \033[0m' COUNTRY
	read -p $'\033[1;33m State/Province: \033[0m' STATE
	read -p $'\033[1;33m City: \033[0m' CITY
	read -p $'\033[1;33m Organization: \033[0m' ORG
	read -p $'\033[1;33m Common Name (e.g. localhost): \033[0m' CN
	read -p $'\033[1;33m Email Address: \033[0m' EMAIL
	read -p $'\033[1;33m Server IP: \033[0m' IP

	echo -e "\033[0;36m---------------------------------------------\033[0m"
}

# === GENERATE SELF-SIGNED SSL CERTIFICATE ===
function SSL() 
{
	log_info "Generating self-signed SSL certificate..."

	SSL_DIR="/etc/apache2/ssl"
	mkdir -p "$SSL_DIR"

	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout "$SSL_DIR/selfsigned.key" \
		-out "$SSL_DIR/selfsigned.crt" \
		-subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/CN=$CN/emailAddress=$EMAIL" &>/dev/null

	log_ok "SSL certificate created at $SSL_DIR"
}

# === ENABLE HTTPS CONFIG IN APACHE ===
function SELFSIGNED() 
{
	log_info "Enabling SSL site configuration..."

	if [[ ! -f files/https-selfsigned.conf ]]; then
		log_err "Missing: files/https-selfsigned.conf"
		exit 1
	fi

	cp files/https-selfsigned.conf /etc/apache2/sites-available/https-selfsigned.conf
	a2ensite https-selfsigned.conf &>/dev/null

	# Add ServerName if not already present
	grep -q "ServerName" /etc/apache2/apache2.conf || echo "ServerName localhost" >> /etc/apache2/apache2.conf

	systemctl reload apache2 &>/dev/null

	log_ok "SSL site enabled and Apache reloaded."
}

# === APACHE CONFIGURATION VALIDATION ===
function CONFIG_TEST() 
{
	log_info "Running Apache configuration test..."

	if apache2ctl configtest &>/dev/null; then
		log_ok "Apache server configured correctly."
	else
		log_err "Apache config test failed. Run 'apache2ctl configtest' manually."
		exit 1
	fi
}

# === SCRIPT EXECUTION ===
HEADER           # Show custom banner
# UPDATE         # Optional: Uncomment to enable updates
APACHE_TEST      # Start/enable Apache
RUN              # Copy HTML and enable SSL
INPUT            # Prompt for certificate fields
SSL              # Generate self-signed certificate
SELFSIGNED       # Enable HTTPS site config
CONFIG_TEST      # Validate Apache config

echo -e "\n${BOLD_GREEN} Script completed successfully! Your HTTPS site should now be live.${RESET}"
