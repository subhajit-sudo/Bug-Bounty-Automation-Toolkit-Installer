#!/bin/bash

# Bug Bounty Automation Toolkit
# Comprehensive installation and execution script for recon and vulnerability scanning tools

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
TOOLS_DIR="$HOME/bugbounty-tools"
RESULTS_DIR="$HOME/bugbounty-results"

# Logging
LOG_FILE="$TOOLS_DIR/installation.log"

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     BUG BOUNTY AUTOMATION TOOLKIT INSTALLER              ║"
    echo "║     Complete Recon & Vulnerability Assessment Suite     ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log() {
    echo -e "${GREEN}[+]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

error() {
    echo -e "${RED}[-]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1" >> "$LOG_FILE"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root for security reasons"
        exit 1
    fi
}

check_internet() {
    if ! ping -c 1 google.com &> /dev/null; then
        error "No internet connection detected"
        exit 1
    fi
}

setup_directories() {
    log "Setting up directories..."
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$RESULTS_DIR"
    cd "$TOOLS_DIR"
}

install_dependencies() {
    log "Installing system dependencies..."
    
    sudo apt-get update
    sudo apt-get install -y \
        git curl wget python3 python3-pip python3-venv \
        golang-go build-essential libssl-dev libffi-dev \
        python3-dev chromium-browser chromium-chromedriver \
        nmap masscan nikto jq unzip ruby ruby-dev \
        libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev \
        phantomjs firefox-geckodriver
    
    # Install Rust (needed for some tools)
    if ! command -v cargo &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    log "Dependencies installed successfully"
}

# ========== SUBDOMAIN ENUMERATION ==========

install_subfinder() {
    log "Installing Subfinder..."
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
}

install_amass() {
    log "Installing Amass..."
    go install -v github.com/owasp-amass/amass/v4/...@master
}

install_assetfinder() {
    log "Installing Assetfinder..."
    go install github.com/tomnomnom/assetfinder@latest
}

# ========== PORT SCANNING ==========

check_nmap() {
    log "Nmap already installed via apt"
}

check_masscan() {
    log "Masscan already installed via apt"
}

# ========== SCREENSHOT CAPTURE ==========

install_eyewitness() {
    log "Installing EyeWitness..."
    cd "$TOOLS_DIR"
    git clone https://github.com/FortyNorthSecurity/EyeWitness.git
    cd EyeWitness/Python/setup
    sudo ./setup.sh
}

install_aquatone() {
    log "Installing Aquatone..."
    cd "$TOOLS_DIR"
    wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
    unzip aquatone_linux_amd64_1.7.0.zip -d aquatone
    chmod +x aquatone/aquatone
    sudo mv aquatone/aquatone /usr/local/bin/
    rm aquatone_linux_amd64_1.7.0.zip
}

# ========== DIRECTORY BRUTE FORCING ==========

install_ffuf() {
    log "Installing ffuf..."
    go install github.com/ffuf/ffuf/v2@latest
}

install_gobuster() {
    log "Installing Gobuster..."
    go install github.com/OJ/gobuster/v3@latest
}

# ========== JAVASCRIPT ANALYSIS ==========

install_linkfinder() {
    log "Installing LinkFinder..."
    cd "$TOOLS_DIR"
    git clone https://github.com/GerbenJavado/LinkFinder.git
    cd LinkFinder
    pip3 install -r requirements.txt
    sudo python3 setup.py install
}

install_gf() {
    log "Installing gf..."
    go install github.com/tomnomnom/gf@latest
    
    # Install gf patterns
    cd "$TOOLS_DIR"
    git clone https://github.com/1ndianl33t/Gf-Patterns
    mkdir -p ~/.gf
    cp -r Gf-Patterns/*.json ~/.gf
}

# ========== PARAMETER DISCOVERY ==========

install_paramspider() {
    log "Installing ParamSpider..."
    cd "$TOOLS_DIR"
    git clone https://github.com/devanshbatham/ParamSpider
    cd ParamSpider
    pip3 install -r requirements.txt
}

install_arjun() {
    log "Installing Arjun..."
    pip3 install arjun
}

# ========== XSS DETECTION ==========

install_dalfox() {
    log "Installing Dalfox..."
    go install github.com/hahwul/dalfox/v2@latest
}

install_xsstrike() {
    log "Installing XSStrike..."
    cd "$TOOLS_DIR"
    git clone https://github.com/s0md3v/XSStrike.git
    cd XSStrike
    pip3 install -r requirements.txt
}

# ========== SQL INJECTION ==========

install_sqlmap() {
    log "Installing SQLMap..."
    cd "$TOOLS_DIR"
    git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
}

install_ghauri() {
    log "Installing Ghauri..."
    pip3 install ghauri
}

# ========== SSRF DISCOVERY ==========

install_gopherus() {
    log "Installing Gopherus..."
    cd "$TOOLS_DIR"
    git clone https://github.com/tarunkant/Gopherus.git
    cd Gopherus
    chmod +x install.sh
    ./install.sh
}

install_interactsh() {
    log "Installing Interactsh..."
    go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
}

# ========== LFI/RFI DETECTION ==========

install_lfisuite() {
    log "Installing LFISuite..."
    cd "$TOOLS_DIR"
    git clone https://github.com/D35m0nd142/LFISuite.git
    cd LFISuite
    pip3 install -r requirements.txt
}

install_lfimap() {
    log "Installing LFIMap..."
    cd "$TOOLS_DIR"
    git clone https://github.com/hansmach1ne/lfimap.git
    cd lfimap
    pip3 install -r requirements.txt
}

# ========== OPEN REDIRECT ==========

install_oralyzer() {
    log "Installing Oralyzer..."
    cd "$TOOLS_DIR"
    git clone https://github.com/r0075h3ll/Oralyzer.git
    cd Oralyzer
    pip3 install -r requirements.txt
}

# ========== SECURITY HEADERS ==========

check_nikto() {
    log "Nikto already installed via apt"
}

install_httpx() {
    log "Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
}

# ========== API RECON ==========

install_postman() {
    log "Installing Postman..."
    cd "$TOOLS_DIR"
    wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    tar -xzf postman.tar.gz
    rm postman.tar.gz
    warn "Postman installed to $TOOLS_DIR/Postman. Run manually with: $TOOLS_DIR/Postman/Postman"
}

install_kiterunner() {
    log "Installing Kiterunner..."
    cd "$TOOLS_DIR"
    git clone https://github.com/assetnote/kiterunner.git
    cd kiterunner
    make build
    sudo ln -s $(pwd)/dist/kr /usr/local/bin/kr
}

# ========== CONTENT DISCOVERY ==========

install_gau() {
    log "Installing gau..."
    go install github.com/lc/gau/v2/cmd/gau@latest
}

install_waybackurls() {
    log "Installing waybackurls..."
    go install github.com/tomnomnom/waybackurls@latest
}

# ========== S3 BUCKET ENUMERATION ==========

install_s3scanner() {
    log "Installing S3Scanner..."
    pip3 install s3scanner
}

# ========== CMS ENUMERATION ==========

install_cmseek() {
    log "Installing CMSeek..."
    cd "$TOOLS_DIR"
    git clone https://github.com/Tuhinshubhra/CMSeeK
    cd CMSeeK
    pip3 install -r requirements.txt
}

# ========== WAF DETECTION ==========

install_wafw00f() {
    log "Installing wafw00f..."
    pip3 install wafw00f
}

# ========== INFORMATION DISCLOSURE ==========

install_gitdumper() {
    log "Installing git-dumper..."
    pip3 install git-dumper
}

# ========== WORDLISTS ==========

install_wordlists() {
    log "Downloading wordlists..."
    cd "$TOOLS_DIR"
    mkdir -p wordlists
    cd wordlists
    
    # SecLists
    git clone https://github.com/danielmiessler/SecLists.git
    
    log "Wordlists downloaded to $TOOLS_DIR/wordlists"
}

# ========== MAIN INSTALLATION ==========

install_all_tools() {
    print_banner
    check_root
    check_internet
    setup_directories
    
    log "Starting installation of all tools..."
    
    install_dependencies
    
    # Subdomain Enumeration
    install_subfinder
    install_amass
    install_assetfinder
    
    # Port Scanning
    check_nmap
    check_masscan
    
    # Screenshot Capture
    install_eyewitness
    install_aquatone
    
    # Directory Brute Forcing
    install_ffuf
    install_gobuster
    
    # JavaScript Analysis
    install_linkfinder
    install_gf
    
    # Parameter Discovery
    install_paramspider
    install_arjun
    
    # XSS Detection
    install_dalfox
    install_xsstrike
    
    # SQL Injection
    install_sqlmap
    install_ghauri
    
    # SSRF Discovery
    install_gopherus
    install_interactsh
    
    # LFI/RFI Detection
    install_lfisuite
    install_lfimap
    
    # Open Redirect
    install_oralyzer
    
    # Security Headers
    check_nikto
    install_httpx
    
    # API Recon
    install_postman
    install_kiterunner
    
    # Content Discovery
    install_gau
    install_waybackurls
    
    # S3 Bucket Enumeration
    install_s3scanner
    
    # CMS Enumeration
    install_cmseek
    
    # WAF Detection
    install_wafw00f
    
    # Information Disclosure
    install_gitdumper
    
    # Wordlists
    install_wordlists
    
    # Add Go bin to PATH if not already there
    if ! grep -q 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc; then
        echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
        log "Added Go bin to PATH in ~/.bashrc"
    fi
    
    log "Installation completed! Please run 'source ~/.bashrc' or restart your terminal"
    log "All tools installed to: $TOOLS_DIR"
    log "Installation log saved to: $LOG_FILE"
}

# ========== AUTOMATED SCANNING ==========

run_full_recon() {
    local domain=$1
    
    if [ -z "$domain" ]; then
        error "Please provide a domain"
        echo "Usage: $0 scan example.com"
        exit 1
    fi
    
    local output_dir="$RESULTS_DIR/$domain/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$output_dir"
    
    log "Starting full reconnaissance on $domain"
    log "Results will be saved to: $output_dir"
    
    # Subdomain Enumeration
    log "Running subdomain enumeration..."
    subfinder -d "$domain" -o "$output_dir/subfinder.txt" 2>/dev/null &
    assetfinder --subs-only "$domain" > "$output_dir/assetfinder.txt" 2>/dev/null &
    amass enum -passive -d "$domain" -o "$output_dir/amass.txt" 2>/dev/null &
    wait
    
    # Combine and sort unique subdomains
    cat "$output_dir"/{subfinder,assetfinder,amass}.txt | sort -u > "$output_dir/all_subdomains.txt"
    log "Found $(wc -l < "$output_dir/all_subdomains.txt") unique subdomains"
    
    # Check live hosts
    log "Checking live hosts with httpx..."
    cat "$output_dir/all_subdomains.txt" | httpx -silent -o "$output_dir/live_hosts.txt"
    
    # Port Scanning
    log "Running port scan with nmap..."
    nmap -iL "$output_dir/live_hosts.txt" -T4 -oN "$output_dir/nmap_scan.txt" &
    
    # Screenshots
    log "Capturing screenshots with Aquatone..."
    cat "$output_dir/live_hosts.txt" | aquatone -out "$output_dir/screenshots" &
    
    # Content Discovery
    log "Running content discovery..."
    cat "$output_dir/live_hosts.txt" | gau > "$output_dir/gau_urls.txt" &
    cat "$output_dir/live_hosts.txt" | waybackurls > "$output_dir/wayback_urls.txt" &
    
    wait
    
    # Combine URLs
    cat "$output_dir"/{gau,wayback}_urls.txt | sort -u > "$output_dir/all_urls.txt"
    
    # WAF Detection
    log "Detecting WAFs..."
    wafw00f -i "$output_dir/live_hosts.txt" -o "$output_dir/waf_detection.txt"
    
    log "Reconnaissance completed! Results saved to: $output_dir"
    echo -e "\n${GREEN}Summary:${NC}"
    echo "  Subdomains found: $(wc -l < "$output_dir/all_subdomains.txt")"
    echo "  Live hosts: $(wc -l < "$output_dir/live_hosts.txt")"
    echo "  URLs discovered: $(wc -l < "$output_dir/all_urls.txt")"
}

# ========== MENU ==========

show_menu() {
    print_banner
    echo "Select an option:"
    echo "  1) Install all tools"
    echo "  2) Run full reconnaissance on a domain"
    echo "  3) Update all tools"
    echo "  4) Exit"
    echo ""
    read -p "Enter choice [1-4]: " choice
    
    case $choice in
        1)
            install_all_tools
            ;;
        2)
            read -p "Enter target domain: " target
            run_full_recon "$target"
            ;;
        3)
            log "Updating all tools..."
            cd "$TOOLS_DIR"
            for dir in */; do
                if [ -d "$dir/.git" ]; then
                    log "Updating $dir"
                    cd "$dir"
                    git pull
                    cd ..
                fi
            done
            go install -v $(go list -f '{{.ImportPath}}' -m all | grep github.com)
            pip3 install --upgrade $(pip3 list --format=freeze | cut -d= -f1)
            log "Update completed"
            ;;
        4)
            exit 0
            ;;
        *)
            error "Invalid choice"
            show_menu
            ;;
    esac
}

# ========== MAIN ==========

main() {
    if [ "$1" == "install" ]; then
        install_all_tools
    elif [ "$1" == "scan" ]; then
        run_full_recon "$2"
    else
        show_menu
    fi
}

main "$@"