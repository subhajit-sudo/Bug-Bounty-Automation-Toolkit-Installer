#!/bin/bash

# Bug Bounty Automation Toolkit - FIXED VERSION
# Addresses PEP 668 externally-managed-environment errors

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
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

error() {
    echo -e "${RED}[-]${NC} $1"
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
    mkdir -p "$(dirname "$LOG_FILE")"
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

setup_pipx() {
    log "Configuring pipx..."
    
    # Ensure pipx path is in PATH
    if ! command -v pipx &> /dev/null; then
        error "pipx not found. Installing pipx..."
        sudo apt-get install -y pipx
    fi
    
    # Ensure pipx is set up
    pipx ensurepath
    
    log "pipx configured successfully"
}

install_dependencies() {
    log "Installing system dependencies..."
    
    # Update package list
    sudo apt-get update
    
    # Install core dependencies
    sudo apt-get install -y \
        git curl wget python3 python3-pip python3-venv python3-full \
        golang-go build-essential libssl-dev libffi-dev \
        python3-dev jq unzip ruby ruby-dev \
        libcurl4-openssl-dev libxml2-dev libxslt1-dev \
        nmap masscan nikto chromium pipx
    
    # Setup pipx
    setup_pipx
    
    # Install webdrivers manually
    log "Installing chromedriver..."
    CHROMEDRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE 2>/dev/null || echo "114.0.5735.90")
    wget -q -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" || {
        warn "Failed to download chromedriver, skipping..."
    }
    if [ -f /tmp/chromedriver.zip ]; then
        sudo unzip -o /tmp/chromedriver.zip -d /usr/local/bin/
        sudo chmod +x /usr/local/bin/chromedriver
        rm /tmp/chromedriver.zip
    fi
    
    log "Installing geckodriver..."
    GECKODRIVER_VERSION=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest | jq -r '.tag_name' 2>/dev/null || echo "v0.33.0")
    wget -q -O /tmp/geckodriver.tar.gz "https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" || {
        warn "Failed to download geckodriver, skipping..."
    }
    if [ -f /tmp/geckodriver.tar.gz ]; then
        sudo tar -xzf /tmp/geckodriver.tar.gz -C /usr/local/bin/
        sudo chmod +x /usr/local/bin/geckodriver
        rm /tmp/geckodriver.tar.gz
    fi
    
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
    
    if [ -d "EyeWitness" ]; then
        log "EyeWitness directory already exists. Updating instead..."
        cd EyeWitness
        git pull
        cd ..
    else
        git clone https://github.com/FortyNorthSecurity/EyeWitness.git
    fi
    
    # Create a virtual environment for EyeWitness
    cd EyeWitness/Python
    python3 -m venv venv
    source venv/bin/activate
    
    # Install requirements if file exists
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        warn "No requirements.txt found for EyeWitness, installing common dependencies..."
        pip install selenium pillow netaddr
    fi
    
    deactivate
    
    # Create wrapper script
    cat > "$TOOLS_DIR/eyewitness-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/EyeWitness/Python"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/EyeWitness.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/eyewitness-wrapper.sh"
    
    if [ ! -f /usr/local/bin/eyewitness ]; then
        sudo ln -s "$TOOLS_DIR/eyewitness-wrapper.sh" /usr/local/bin/eyewitness
    fi
    
    log "EyeWitness installed with virtual environment"
}

install_aquatone() {
    log "Installing Aquatone..."
    cd "$TOOLS_DIR"
    wget -q https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
    unzip -o aquatone_linux_amd64_1.7.0.zip -d aquatone
    chmod +x aquatone/aquatone
    sudo mv aquatone/aquatone /usr/local/bin/ 2>/dev/null || sudo cp aquatone/aquatone /usr/local/bin/
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
    
    if [ -d "LinkFinder" ]; then
        cd LinkFinder
        git pull
    else
        git clone https://github.com/GerbenJavado/LinkFinder.git
        cd LinkFinder
    fi
    
    # Create venv and wrapper
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        pip install jsbeautifier argparse
    fi
    
    deactivate
    
    cat > "$TOOLS_DIR/linkfinder-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/LinkFinder"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/linkfinder.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/linkfinder-wrapper.sh"
    
    if [ ! -f /usr/local/bin/linkfinder ]; then
        sudo ln -s "$TOOLS_DIR/linkfinder-wrapper.sh" /usr/local/bin/linkfinder
    fi
    
    log "LinkFinder installed with virtual environment"
}

install_gf() {
    log "Installing gf..."
    go install github.com/tomnomnom/gf@latest
    
    # Install gf patterns
    cd "$TOOLS_DIR"
    if [ -d "Gf-Patterns" ]; then
        cd Gf-Patterns
        git pull
    else
        git clone https://github.com/1ndianl33t/Gf-Patterns
    fi
    mkdir -p ~/.gf
    cp -r Gf-Patterns/*.json ~/.gf 2>/dev/null || warn "No patterns found to copy"
}

# ========== PARAMETER DISCOVERY ==========

install_paramspider() {
    log "Installing ParamSpider..."
    cd "$TOOLS_DIR"
    
    if [ -d "ParamSpider" ]; then
        cd ParamSpider
        git pull
    else
        git clone https://github.com/devanshbatham/ParamSpider
        cd ParamSpider
    fi
    
    # Create venv and wrapper
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        pip install requests
    fi
    
    deactivate
    
    cat > "$TOOLS_DIR/paramspider-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/ParamSpider"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/paramspider.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/paramspider-wrapper.sh"
    
    if [ ! -f /usr/local/bin/paramspider ]; then
        sudo ln -s "$TOOLS_DIR/paramspider-wrapper.sh" /usr/local/bin/paramspider
    fi
    
    log "ParamSpider installed with virtual environment"
}

install_arjun() {
    log "Installing Arjun..."
    pipx install arjun
}

# ========== XSS DETECTION ==========

install_dalfox() {
    log "Installing Dalfox..."
    go install github.com/hahwul/dalfox/v2@latest
}

install_xsstrike() {
    log "Installing XSStrike..."
    cd "$TOOLS_DIR"
    
    if [ -d "XSStrike" ]; then
        log "XSStrike directory already exists. Updating instead..."
        cd XSStrike
        git pull
    else
        git clone https://github.com/s0md3v/XSStrike.git
        cd XSStrike
    fi
    
    # Create virtual environment for XSStrike
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        warn "No requirements.txt found, installing common dependencies..."
        pip install requests fuzzywuzzy
    fi
    
    deactivate
    
    # Create wrapper script
    cat > "$TOOLS_DIR/xsstrike-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/XSStrike"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/xsstrike.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/xsstrike-wrapper.sh"
    
    if [ ! -f /usr/local/bin/xsstrike ]; then
        sudo ln -s "$TOOLS_DIR/xsstrike-wrapper.sh" /usr/local/bin/xsstrike
    fi
    
    log "XSStrike installed with virtual environment"
}

# ========== SQL INJECTION ==========

install_sqlmap() {
    log "Installing SQLMap..."
    cd "$TOOLS_DIR"
    
    if [ -d "sqlmap-dev" ]; then
        cd sqlmap-dev
        git pull
    else
        git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
    fi
    
    # SQLMap works fine without installation, just needs Python
    if [ ! -f /usr/local/bin/sqlmap ]; then
        sudo ln -s "$TOOLS_DIR/sqlmap-dev/sqlmap.py" /usr/local/bin/sqlmap
    fi
}

install_ghauri() {
    log "Installing Ghauri..."
    cd "$TOOLS_DIR"
    
    if [ -d "ghauri" ]; then
        cd ghauri
        git pull
    else
        git clone https://github.com/r0oth3x49/ghauri.git
        cd ghauri
    fi
    
    # Create virtual environment
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    fi
    
    # Install in development mode if setup.py exists
    if [ -f setup.py ]; then
        pip install -e .
    fi
    
    deactivate
    
    # Create wrapper
    cat > "$TOOLS_DIR/ghauri-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/ghauri"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/ghauri.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/ghauri-wrapper.sh"
    
    if [ ! -f /usr/local/bin/ghauri ]; then
        sudo ln -s "$TOOLS_DIR/ghauri-wrapper.sh" /usr/local/bin/ghauri
    fi
    
    log "Ghauri installed with virtual environment"
}

# ========== SSRF DISCOVERY ==========

install_gopherus() {
    log "Installing Gopherus..."
    cd "$TOOLS_DIR"
    
    if [ -d "Gopherus" ]; then
        cd Gopherus
        git pull
    else
        git clone https://github.com/tarunkant/Gopherus.git
        cd Gopherus
    fi
    
    # Create virtual environment
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        pip install requests
    fi
    
    deactivate
    
    # Create wrapper
    cat > "$TOOLS_DIR/gopherus-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/Gopherus"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/gopherus.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/gopherus-wrapper.sh"
    
    if [ ! -f /usr/local/bin/gopherus ]; then
        sudo ln -s "$TOOLS_DIR/gopherus-wrapper.sh" /usr/local/bin/gopherus
    fi
}

install_interactsh() {
    log "Installing Interactsh..."
    go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
}

# ========== LFI/RFI DETECTION ==========

install_lfisuite() {
    log "Installing LFISuite..."
    cd "$TOOLS_DIR"
    
    if [ -d "LFISuite" ]; then
        cd LFISuite
        git pull
    else
        git clone https://github.com/D35m0nd142/LFISuite.git
        cd LFISuite
    fi
    
    # Create virtual environment
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        warn "No requirements.txt, installing common dependencies..."
        pip install requests colorama
    fi
    
    deactivate
    
    # Create wrapper
    cat > "$TOOLS_DIR/lfisuite-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/LFISuite"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/lfisuite.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/lfisuite-wrapper.sh"
    
    if [ ! -f /usr/local/bin/lfisuite ]; then
        sudo ln -s "$TOOLS_DIR/lfisuite-wrapper.sh" /usr/local/bin/lfisuite
    fi
}

install_lfimap() {
    log "Installing LFIMap..."
    cd "$TOOLS_DIR"
    
    if [ -d "lfimap" ]; then
        cd lfimap
        git pull
    else
        git clone https://github.com/hansmach1ne/lfimap.git
        cd lfimap
    fi
    
    # Create venv and wrapper
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        pip install requests
    fi
    
    deactivate
    
    cat > "$TOOLS_DIR/lfimap-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/lfimap"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/lfimap.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/lfimap-wrapper.sh"
    
    if [ ! -f /usr/local/bin/lfimap ]; then
        sudo ln -s "$TOOLS_DIR/lfimap-wrapper.sh" /usr/local/bin/lfimap
    fi
    
    log "LFIMap installed with virtual environment"
}

# ========== OPEN REDIRECT ==========

install_oralyzer() {
    log "Installing Oralyzer..."
    cd "$TOOLS_DIR"
    
    if [ -d "Oralyzer" ]; then
        cd Oralyzer
        git pull
    else
        git clone https://github.com/r0075h3ll/Oralyzer.git
        cd Oralyzer
    fi
    
    # Create venv and wrapper
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        pip install requests
    fi
    
    deactivate
    
    cat > "$TOOLS_DIR/oralyzer-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/Oralyzer"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/oralyzer.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/oralyzer-wrapper.sh"
    
    if [ ! -f /usr/local/bin/oralyzer ]; then
        sudo ln -s "$TOOLS_DIR/oralyzer-wrapper.sh" /usr/local/bin/oralyzer
    fi
    
    log "Oralyzer installed with virtual environment"
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
    wget -q https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    tar -xzf postman.tar.gz
    rm postman.tar.gz
    warn "Postman installed to $TOOLS_DIR/Postman. Run manually with: $TOOLS_DIR/Postman/Postman"
}

install_kiterunner() {
    log "Installing Kiterunner..."
    cd "$TOOLS_DIR"
    
    if [ -d "kiterunner" ]; then
        cd kiterunner
        git pull
    else
        git clone https://github.com/assetnote/kiterunner.git
        cd kiterunner
    fi
    
    make build
    
    if [ ! -f /usr/local/bin/kr ]; then
        sudo ln -s "$(pwd)/dist/kr" /usr/local/bin/kr
    fi
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
    pipx install s3scanner
}

# ========== CMS ENUMERATION ==========

install_cmseek() {
    log "Installing CMSeek..."
    cd "$TOOLS_DIR"
    
    if [ -d "CMSeeK" ]; then
        cd CMSeeK
        git pull
    else
        git clone https://github.com/Tuhinshubhra/CMSeeK
        cd CMSeeK
    fi
    
    # Create virtual environment
    python3 -m venv venv
    source venv/bin/activate
    
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    else
        warn "No requirements.txt, installing common dependencies..."
        pip install requests beautifulsoup4
    fi
    
    deactivate
    
    # Create wrapper
    cat > "$TOOLS_DIR/cmseek-wrapper.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/bugbounty-tools/CMSeeK"
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/cmseek.py" "$@"
deactivate
EOF
    chmod +x "$TOOLS_DIR/cmseek-wrapper.sh"
    
    if [ ! -f /usr/local/bin/cmseek ]; then
        sudo ln -s "$TOOLS_DIR/cmseek-wrapper.sh" /usr/local/bin/cmseek
    fi
}

# ========== WAF DETECTION ==========

install_wafw00f() {
    log "Installing wafw00f..."
    pipx install wafw00f
}

# ========== INFORMATION DISCLOSURE ==========

install_gitdumper() {
    log "Installing git-dumper..."
    pipx install git-dumper
}

# ========== WORDLISTS ==========

install_wordlists() {
    log "Downloading wordlists..."
    cd "$TOOLS_DIR"
    mkdir -p wordlists
    cd wordlists
    
    # SecLists
    if [ -d "SecLists" ]; then
        cd SecLists
        git pull
    else
        git clone https://github.com/danielmiessler/SecLists.git
    fi
    
    log "Wordlists downloaded to $TOOLS_DIR/wordlists"
}

# ========== MAIN INSTALLATION ==========

install_all_tools() {
    print_banner
    check_root
    check_internet
    setup_directories
    
    # Export PATH to include Go and Rust binaries for the current session
    export PATH=$PATH:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.local/bin
    
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
    
    # Add paths to bashrc if not already there
    if ! grep -q 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc; then
        echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
        log "Added Go bin to PATH in ~/.bashrc"
    fi
    
    if ! grep -q 'export PATH=$PATH:$HOME/.local/bin' ~/.bashrc; then
        echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
        log "Added .local/bin to PATH in ~/.bashrc"
    fi
    
    if ! grep -q 'export PATH=$PATH:$HOME/.cargo/bin' ~/.bashrc; then
        echo 'export PATH=$PATH:$HOME/.cargo/bin' >> ~/.bashrc
        log "Added cargo/bin to PATH in ~/.bashrc"
    fi
    
    log "Installation completed! Please run 'source ~/.bashrc' or restart your terminal"
    log "All tools installed to: $TOOLS_DIR"
    log "Installation log saved to: $LOG_FILE"
}

# ========== UPDATE TOOLS ==========

update_all_tools() {
    log "Updating all tools..."
    
    export PATH=$PATH:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.local/bin
    
    # Update Go tools
    log "Updating Go-based tools..."
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    go install -v github.com/owasp-amass/amass/v4/...@master
    go install github.com/tomnomnom/assetfinder@latest
    go install github.com/ffuf/ffuf/v2@latest
    go install github.com/OJ/gobuster/v3@latest
    go install github.com/tomnomnom/gf@latest
    go install github.com/hahwul/dalfox/v2@latest
    go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    go install github.com/lc/gau/v2/cmd/gau@latest
    go install github.com/tomnomnom/waybackurls@latest
    
    # Update Git repositories
    log "Updating Git-based tools..."
    cd "$TOOLS_DIR"
    
    for repo in EyeWitness XSStrike Gopherus LFISuite lfimap Oralyzer kiterunner CMSeeK sqlmap-dev LinkFinder ParamSpider Gf-Patterns; do
        if [ -d "$repo" ]; then
            log "Updating $repo..."
            cd "$repo"
            git pull
            cd "$TOOLS_DIR"
        fi
    done
    
    # Update pipx tools
    log "Updating pipx-based tools..."
    pipx upgrade-all
    
    log "All tools updated successfully!"
}

# ========== AUTOMATED SCANNING ==========

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
    
    # Ensure PATH includes Go binaries
    export PATH=$PATH:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.local/bin
    
    log "Starting full reconnaissance on $domain"
    log "Results will be saved to: $output_dir"
    
    # Subdomain Enumeration
    log "Running subdomain enumeration..."
    
    # Run tools in parallel but capture any output
    if command -v subfinder &> /dev/null; then
        subfinder -d "$domain" -o "$output_dir/subfinder.txt" 2>/dev/null &
        SUBFINDER_PID=$!
    else
        warn "subfinder not found, skipping..."
        touch "$output_dir/subfinder.txt"
    fi
    
    if command -v assetfinder &> /dev/null; then
        assetfinder --subs-only "$domain" > "$output_dir/assetfinder.txt" 2>/dev/null &
        ASSETFINDER_PID=$!
    else
        warn "assetfinder not found, skipping..."
        touch "$output_dir/assetfinder.txt"
    fi
    
    if command -v amass &> /dev/null; then
        amass enum -passive -d "$domain" -o "$output_dir/amass.txt" 2>/dev/null &
        AMASS_PID=$!
    else
        warn "amass not found, skipping..."
        touch "$output_dir/amass.txt"
    fi
    
    # Wait for subdomain enumeration to complete
    wait 2>/dev/null
    
    # Also add the main domain
    echo "$domain" >> "$output_dir/all_subdomains.txt"
    
    # Combine and sort unique subdomains
    cat "$output_dir"/{subfinder,assetfinder,amass}.txt 2>/dev/null | sort -u >> "$output_dir/all_subdomains.txt"
    
    # Remove empty lines and duplicates
    sed -i '/^$/d' "$output_dir/all_subdomains.txt" 2>/dev/null
    sort -u "$output_dir/all_subdomains.txt" -o "$output_dir/all_subdomains.txt"
    
    local subdomain_count=$(wc -l < "$output_dir/all_subdomains.txt" 2>/dev/null || echo "0")
    log "Found $subdomain_count unique subdomains"
    
    if [ "$subdomain_count" -eq 0 ]; then
        warn "No subdomains found. The domain might not exist or tools need API keys."
        warn "Check: https://github.com/projectdiscovery/subfinder#post-installation-instructions"
        return 1
    fi
    
    # Check live hosts
    log "Checking live hosts with httpx..."
    if command -v httpx &> /dev/null; then
        cat "$output_dir/all_subdomains.txt" | httpx -silent -o "$output_dir/live_hosts.txt" 2>/dev/null
    else
        warn "httpx not found, skipping live host detection..."
        cp "$output_dir/all_subdomains.txt" "$output_dir/live_hosts.txt"
    fi
    
    local live_count=$(wc -l < "$output_dir/live_hosts.txt" 2>/dev/null || echo "0")
    
    if [ "$live_count" -eq 0 ]; then
        warn "No live hosts found. Trying to add http/https prefixes..."
        while IFS= read -r host; do
            echo "http://$host" >> "$output_dir/live_hosts.txt"
            echo "https://$host" >> "$output_dir/live_hosts.txt"
        done < "$output_dir/all_subdomains.txt"
    fi
    
    log "Found $live_count live hosts"
    
    # Only continue with scanning if we have live hosts
    if [ "$live_count" -gt 0 ]; then
        # Port Scanning (background)
        log "Running port scan with nmap..."
        if command -v nmap &> /dev/null; then
            nmap -iL "$output_dir/live_hosts.txt" -T4 -oN "$output_dir/nmap_scan.txt" 2>/dev/null &
            NMAP_PID=$!
        else
            warn "nmap not found, skipping port scan..."
        fi
        
        # Screenshots (background)
        log "Capturing screenshots with Aquatone..."
        if command -v aquatone &> /dev/null; then
            cat "$output_dir/live_hosts.txt" | aquatone -out "$output_dir/screenshots" 2>/dev/null &
            AQUATONE_PID=$!
        else
            warn "aquatone not found, skipping screenshots..."
        fi
        
        # Content Discovery (background)
        log "Running content discovery..."
        if command -v gau &> /dev/null; then
            cat "$output_dir/live_hosts.txt" | gau > "$output_dir/gau_urls.txt" 2>/dev/null &
            GAU_PID=$!
        else
            warn "gau not found, skipping..."
            touch "$output_dir/gau_urls.txt"
        fi
        
        if command -v waybackurls &> /dev/null; then
            cat "$output_dir/live_hosts.txt" | waybackurls > "$output_dir/wayback_urls.txt" 2>/dev/null &
            WAYBACK_PID=$!
        else
            warn "waybackurls not found, skipping..."
            touch "$output_dir/wayback_urls.txt"
        fi
        
        # Wait for background processes
        wait 2>/dev/null
        
        # Combine URLs
        cat "$output_dir"/{gau,wayback}_urls.txt 2>/dev/null | sort -u > "$output_dir/all_urls.txt"
        
        # WAF Detection
        log "Detecting WAFs..."
        if command -v wafw00f &> /dev/null; then
            # Extract just the hosts without http/https for wafw00f
            cat "$output_dir/live_hosts.txt" | sed 's|https\?://||g' | sed 's|/.*||g' > "$output_dir/hosts_only.txt"
            
            if [ -s "$output_dir/hosts_only.txt" ]; then
                wafw00f -i "$output_dir/hosts_only.txt" -o "$output_dir/waf_detection.txt" 2>/dev/null || {
                    warn "wafw00f encountered an error, but continuing..."
                }
            fi
        else
            warn "wafw00f not found, skipping WAF detection..."
        fi
    else
        warn "No live hosts found, skipping port scanning and other active recon..."
    fi
    
    log "Reconnaissance completed! Results saved to: $output_dir"
    echo -e "\n${GREEN}Summary:${NC}"
    echo "  Subdomains found: $subdomain_count"
    echo "  Live hosts: $live_count"
    echo "  URLs discovered: $(wc -l < "$output_dir/all_urls.txt" 2>/dev/null || echo "0")"
    echo ""
    echo "Results directory: $output_dir"
}

# ========== MENU ==========

show_menu() {
    print_banner
    echo "Select an option:"
    echo "  1) Install all tools"
    echo "  2) Run full reconnaissance on a domain"
    echo "  3) Update all tools"
    echo "  4) Test tool installation"
    echo "  5) Exit"
    echo ""
    read -p "Enter choice [1-5]: " choice
    
    case $choice in
        1)
            install_all_tools
            ;;
        2)
            read -p "Enter domain to scan: " domain
            run_full_recon "$domain"
            ;;
        3)
            update_all_tools
            ;;
        4)
            test_tools
            ;;
        5)
            log "Exiting..."
            exit 0
            ;;
        *)
            error "Invalid choice"
            show_menu
            ;;
    esac
}

# ========== TEST TOOLS ==========

test_tools() {
    log "Testing installed tools..."
    echo ""
    
    export PATH=$PATH:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.local/bin
    
    # Go-based tools
    echo -e "${BLUE}Go-based Tools:${NC}"
    for tool in subfinder amass assetfinder ffuf gobuster gf dalfox interactsh-client httpx gau waybackurls; do
        if command -v $tool &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool"
        else
            echo -e "  ${RED}✗${NC} $tool"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Python-based Tools:${NC}"
    for tool in linkfinder paramspider arjun xsstrike sqlmap ghauri gopherus lfisuite lfimap oralyzer eyewitness cmseek wafw00f git-dumper s3scanner; do
        if command -v $tool &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool"
        else
            echo -e "  ${RED}✗${NC} $tool"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Binary Tools:${NC}"
    for tool in nmap masscan nikto aquatone kr; do
        if command -v $tool &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool"
        else
            echo -e "  ${RED}✗${NC} $tool"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Wordlists:${NC}"
    if [ -d "$TOOLS_DIR/wordlists/SecLists" ]; then
        echo -e "  ${GREEN}✓${NC} SecLists ($TOOLS_DIR/wordlists/SecLists)"
    else
        echo -e "  ${RED}✗${NC} SecLists"
    fi
    
    echo ""
    log "Tool testing complete!"
    echo ""
    read -p "Press Enter to return to menu..."
    show_menu
}

# ========== MAIN EXECUTION ==========

# If script is run with arguments
if [ $# -gt 0 ]; then
    case $1 in
        install)
            install_all_tools
            ;;
        scan)
            if [ -z "$2" ]; then
                error "Please provide a domain to scan"
                echo "Usage: $0 scan example.com"
                exit 1
            fi
            run_full_recon "$2"
            ;;
        update)
            update_all_tools
            ;;
        test)
            test_tools
            ;;
        *)
            echo "Usage: $0 {install|scan <domain>|update|test}"
            exit 1
            ;;
    esac
else
    # Show interactive menu if no arguments
    show_menu
fi
