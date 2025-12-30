# 🎯 Bug Bounty Automation Toolkit

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-green.svg)
![Bash](https://img.shields.io/badge/bash-5.0+-orange.svg)
![Contributions](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)

**A comprehensive, automated toolkit for bug bounty hunters and penetration testers**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Tools Included](#-tools-included) • [Contributing](#-contributing)

</div>

---

## 📋 Overview

The Bug Bounty Automation Toolkit is an all-in-one solution that automates the installation and execution of 30+ essential security testing tools. Whether you're a seasoned bug bounty hunter or just starting out, this toolkit streamlines your reconnaissance and vulnerability assessment workflow.

### ✨ Key Highlights

- 🚀 **One-Click Installation**: Install all tools with a single command
- 🔄 **Automated Workflows**: Run complete reconnaissance scans automatically
- 📊 **Organized Results**: Structured output directories for easy analysis
- 🎨 **User-Friendly**: Colored output and interactive menu system
- 📝 **Comprehensive Logging**: Track all operations and errors
- 🔧 **Modular Design**: Use individual tools or complete workflows

---

## 🎁 Features

### 🔍 Reconnaissance & Discovery
- **Subdomain Enumeration**: Discover subdomains using multiple sources
- **Port Scanning**: Identify open ports and services
- **Content Discovery**: Find hidden directories and files
- **Screenshot Capture**: Visual reconnaissance of web applications
- **API Discovery**: Enumerate API endpoints and routes

### 🛡️ Vulnerability Assessment
- **XSS Detection**: Automated cross-site scripting testing
- **SQL Injection**: Database vulnerability scanning
- **SSRF Testing**: Server-side request forgery checks
- **LFI/RFI Detection**: File inclusion vulnerability testing
- **Open Redirect**: URL redirection vulnerability scanning

### 🔐 Security Analysis
- **WAF Detection**: Identify web application firewalls
- **Security Headers**: Analyze HTTP security headers
- **CMS Enumeration**: Detect and fingerprint CMS platforms
- **JavaScript Analysis**: Extract endpoints from JS files
- **Parameter Discovery**: Find hidden parameters

---

## 🛠️ Tools Included

<details>
<summary><b>Subdomain Enumeration (3 tools)</b></summary>

- [Subfinder](https://github.com/projectdiscovery/subfinder) - Fast passive subdomain enumeration
- [Amass](https://github.com/owasp-amass/amass) - OWASP network mapping tool
- [Assetfinder](https://github.com/tomnomnom/assetfinder) - Find domains and subdomains

</details>

<details>
<summary><b>Port Scanning (2 tools)</b></summary>

- [Nmap](https://nmap.org/) - Network exploration and security auditing
- [Masscan](https://github.com/robertdavidgraham/masscan) - Fast TCP port scanner

</details>

<details>
<summary><b>Screenshot Capture (2 tools)</b></summary>

- [EyeWitness](https://github.com/FortyNorthSecurity/EyeWitness) - Screenshot web applications
- [Aquatone](https://github.com/michenriksen/aquatone) - Visual inspection tool

</details>

<details>
<summary><b>Directory Brute Forcing (2 tools)</b></summary>

- [ffuf](https://github.com/ffuf/ffuf) - Fast web fuzzer
- [Gobuster](https://github.com/OJ/gobuster) - Directory/DNS/VHost busting

</details>

<details>
<summary><b>JavaScript Analysis (2 tools)</b></summary>

- [LinkFinder](https://github.com/GerbenJavado/LinkFinder) - Discover endpoints in JS files
- [gf](https://github.com/tomnomnom/gf) - Grep-friendly pattern matcher

</details>

<details>
<summary><b>Parameter Discovery (2 tools)</b></summary>

- [ParamSpider](https://github.com/devanshbatham/ParamSpider) - Mining parameters from dark corners
- [Arjun](https://github.com/s0md3v/Arjun) - HTTP parameter discovery suite

</details>

<details>
<summary><b>XSS Detection (2 tools)</b></summary>

- [Dalfox](https://github.com/hahwul/dalfox) - Powerful XSS scanner
- [XSStrike](https://github.com/s0md3v/XSStrike) - Advanced XSS detection suite

</details>

<details>
<summary><b>SQL Injection Testing (2 tools)</b></summary>

- [SQLMap](https://github.com/sqlmapproject/sqlmap) - Automatic SQL injection tool
- [Ghauri](https://github.com/r0oth3x49/ghauri) - Advanced SQL injection detection

</details>

<details>
<summary><b>SSRF Discovery (2 tools)</b></summary>

- [Gopherus](https://github.com/tarunkant/Gopherus) - Generate gopher payloads
- [Interactsh](https://github.com/projectdiscovery/interactsh) - OOB interaction gathering

</details>

<details>
<summary><b>LFI/RFI Detection (2 tools)</b></summary>

- [LFISuite](https://github.com/D35m0nd142/LFISuite) - Local file inclusion exploitation
- [LFIMap](https://github.com/hansmach1ne/lfimap) - LFI discovery and exploitation

</details>

<details>
<summary><b>Open Redirect Detection (1 tool)</b></summary>

- [Oralyzer](https://github.com/r0075h3ll/Oralyzer) - Open redirect analyzer

</details>

<details>
<summary><b>Security Headers Check (2 tools)</b></summary>

- [Nikto](https://github.com/sullo/nikto) - Web server scanner
- [httpx](https://github.com/projectdiscovery/httpx) - Fast HTTP toolkit

</details>

<details>
<summary><b>API Reconnaissance (2 tools)</b></summary>

- [Postman](https://www.postman.com/) - API development platform
- [Kiterunner](https://github.com/assetnote/kiterunner) - Contextual content discovery

</details>

<details>
<summary><b>Content Discovery (2 tools)</b></summary>

- [gau](https://github.com/lc/gau) - Fetch known URLs from AlienVault's OTX
- [waybackurls](https://github.com/tomnomnom/waybackurls) - Fetch URLs from Wayback Machine

</details>

<details>
<summary><b>S3 Bucket Enumeration (1 tool)</b></summary>

- [S3Scanner](https://github.com/sa7mon/S3Scanner) - Scan for open S3 buckets

</details>

<details>
<summary><b>CMS Enumeration (1 tool)</b></summary>

- [CMSeek](https://github.com/Tuhinshubhra/CMSeeK) - CMS detection and exploitation

</details>

<details>
<summary><b>WAF Detection (1 tool)</b></summary>

- [wafw00f](https://github.com/EnableSecurity/wafw00f) - Web application firewall detection

</details>

<details>
<summary><b>Information Disclosure (1 tool)</b></summary>

- [git-dumper](https://github.com/arthaud/git-dumper) - Dump exposed .git directories

</details>

<details>
<summary><b>Wordlists</b></summary>

- [SecLists](https://github.com/danielmiessler/SecLists) - The ultimate security wordlists

</details>

---

## 📥 Installation

### Prerequisites

- **Operating System**: Linux (Ubuntu/Debian recommended)
- **User Privileges**: Non-root user with sudo access
- **Internet Connection**: Required for downloading tools
- **Disk Space**: ~5GB free space recommended

### Quick Install

```bash
# Clone the repository
git clone https://github.com/subhojit64/Bug-Bounty-Automation-Toolkit-Installer.git

# Navigate to the directory
cd Bug-Bounty-Automation-Toolkit-Installer-main

# Make the script executable
chmod +x bugbounty_toolkit.sh

# Run the installation
./bugbounty_toolkit.sh install
```

### Post-Installation

After installation, reload your shell configuration:

```bash
source ~/.bashrc
# or
source ~/.zshrc
```

---

## 🚀 Usage

### Interactive Menu

Launch the interactive menu for easy navigation:

```bash
./bugbounty_toolkit.sh
```

### Direct Commands

#### Install All Tools
```bash
./bugbounty_toolkit.sh install
```

#### Run Full Reconnaissance
```bash
./bugbounty_toolkit.sh scan example.com
```

### Manual Tool Usage

After installation, all tools are available in your PATH:

```bash
# Subdomain enumeration
subfinder -d example.com
amass enum -d example.com
assetfinder example.com

# Port scanning
nmap -sV example.com
masscan -p1-65535 example.com

# Web fuzzing
ffuf -u https://example.com/FUZZ -w wordlist.txt
gobuster dir -u https://example.com -w wordlist.txt

# XSS testing
dalfox url https://example.com
python3 xsstrike.py -u https://example.com

# And many more...
```

---

## 📂 Directory Structure

```
~/bugbounty-tools/              # All installed tools
├── Subfinder/
├── Amass/
├── EyeWitness/
├── LinkFinder/
├── XSStrike/
├── sqlmap-dev/
├── wordlists/
│   └── SecLists/
└── installation.log

~/bugbounty-results/            # Scan results
└── example.com/
    └── 20240101_120000/
        ├── subfinder.txt
        ├── live_hosts.txt
        ├── nmap_scan.txt
        ├── screenshots/
        ├── all_urls.txt
        └── waf_detection.txt
```

---

## 🔄 Automated Reconnaissance Workflow

When you run `./bugbounty_toolkit.sh scan example.com`, the following automated workflow executes:

```
1. Subdomain Enumeration
   ├── Subfinder
   ├── Amass (passive)
   └── Assetfinder
   └── Output: all_subdomains.txt

2. Live Host Detection
   └── httpx
   └── Output: live_hosts.txt

3. Port Scanning
   └── Nmap
   └── Output: nmap_scan.txt

4. Screenshot Capture
   └── Aquatone
   └── Output: screenshots/

5. Content Discovery
   ├── gau
   └── waybackurls
   └── Output: all_urls.txt

6. WAF Detection
   └── wafw00f
   └── Output: waf_detection.txt

7. Summary Report
   └── Statistics and findings
```

---

## ⚙️ Configuration

### API Keys (Optional)

Some tools work better with API keys. Configure them after installation:

```bash
# Subfinder
nano ~/.config/subfinder/provider-config.yaml

# Amass
nano ~/.config/amass/config.ini
```

### Custom Wordlists

Add your custom wordlists to:
```bash
~/bugbounty-tools/wordlists/custom/
```

---

## 🎓 Best Practices

1. **Always Get Permission**: Only scan targets you have explicit permission to test
2. **Rate Limiting**: Use appropriate delays to avoid overwhelming targets
3. **Scope Management**: Stay within the defined scope of your engagement
4. **Data Privacy**: Handle discovered data responsibly and securely
5. **Documentation**: Keep detailed notes of your findings
6. **Responsible Disclosure**: Follow proper vulnerability disclosure procedures

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: Tools not found in PATH
```bash
# Solution
source ~/.bashrc
# or manually add
export PATH=$PATH:$HOME/go/bin
```

**Issue**: Permission denied errors
```bash
# Solution
chmod +x bugbounty_toolkit.sh
```

**Issue**: Python module not found
```bash
# Solution
pip3 install --user <module-name>
```

**Issue**: Go tools not installing
```bash
# Solution
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

---

## 🔄 Updating Tools

Keep your tools up-to-date:

```bash
# Through the menu
./bugbounty_toolkit.sh
# Select option 3

# Or manually update Go tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Update Python tools
pip3 install --upgrade tool-name
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Areas for Contribution

- 🐛 Bug fixes and error handling
- 🆕 New tool integrations
- 📝 Documentation improvements
- ✨ Feature enhancements
- 🧪 Testing and validation

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

**IMPORTANT**: This toolkit is intended for authorized security testing only. Users are responsible for complying with all applicable laws and regulations. The authors and contributors are not responsible for any misuse or damage caused by this tool.

### Legal Notice

- ✅ Only use on targets you have explicit permission to test
- ✅ Comply with bug bounty program rules
- ✅ Follow responsible disclosure practices
- ❌ Never use for unauthorized access
- ❌ Do not violate computer fraud and abuse laws

---

## 🌟 Acknowledgments

Special thanks to all the tool developers and the bug bounty community:

- [ProjectDiscovery](https://github.com/projectdiscovery) - Amazing security tools
- [OWASP](https://owasp.org/) - Security resources and tools
- [Tom Hudson (tomnomnom)](https://github.com/tomnomnom) - Essential Go tools
- All open-source contributors who make these tools possible

---

## 📞 Support & Community

- 🐛 **Report Issues**: [GitHub Issues](https://github.com/yourusername/bugbounty-automation-toolkit/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/bugbounty-automation-toolkit/discussions)
- 📧 **Contact**: subhojitnandi64@gmail.com

---

## 📊 Stats

![GitHub stars](https://img.shields.io/github/stars/yourusername/bugbounty-automation-toolkit?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/bugbounty-automation-toolkit?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/yourusername/bugbounty-automation-toolkit?style=social)

---

<div align="center">

**Made with ❤️ by bug bounty hunters, for bug bounty hunters**

If this project helped you, consider giving it a ⭐!

</div>
