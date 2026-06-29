████████╗███████╗ ██████╗██╗  ██╗
╚══██╔══╝██╔════╝██╔════╝██║  ██║
   ██║   █████╗  ██║     ███████║
   ██║   ██╔══╝  ██║     ██╔══██║
   ██║   ███████╗╚██████╗██║  ██║
   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝

      TECH INTELLIGENCE SCANNER v2.0
       Interactive Network Reconnaissance


# Clone or download the script
git clone https://github.com/techintelligence100-wq/Tech-Intelligence.git
cd tech-intelligence-scanner

# Make it executable
chmod +x tech_intel_scanner.sh

# Run it
./tech_intel_scanner.sh


STEP 1: Target Selection
──────────────────────────────────────────────
Target: 10.10.10.1

STEP 2: Select Scan Type
──────────────────────────────────────────────
  1) Ping Sweep
  2) Quick Scan
  3) Standard Scan
  4) Comprehensive
  5) Vulnerability Audit
  6) Stealth Scan
  7) Full Scan
  8) Custom Scan

Choice [1-8]:



STEP 1: Target Selection
──────────────────────────────────────────────
Target: scanme.nmap.org

STEP 2: Select Scan Type
──────────────────────────────────────────────
Choice [1-8]: 3

STEP 3: Scan Speed
──────────────────────────────────────────────
Choice [0-6]: 4

STEP 4: Port Selection
──────────────────────────────────────────────
Choice [1-3]: 1

STEP 5: Report Format
──────────────────────────────────────────────
Choice [1-4]: 4

STEP 6: Review & Confirm
──────────────────────────────────────────────
  Target:      scanme.nmap.org
  Scan Mode:   Standard Scan
  Timing:      -T4
  Ports:       Mode default
  Format:      all

Start scan? [Y/n]: Y

════════════════════════════════════════════════
[*] Executing: nmap -T4 -sS -sV -sC --open scanme.nmap.org -oA reports/scan_20250629_143022
════════════════════════════════════════════════

[*] Scanning scanme.nmap.org ...

[✓] Reports saved:
  reports/scan_20250629_143022.txt   (plain text)
  reports/scan_20250629_143022.xml   (XML)
  reports/scan_20250629_143022.gnmap (grepable)
  reports/scan_20250629_143022.html  (HTML)

════════════════════════════════════════════════
  ✓ Scan completed successfully!
════════════════════════════════════════════════

What would you like to do?
  1) Run another scan
  2) Exit

Choice [1-2]:


tech-intelligence-scanner/
├── tech_intel_scanner.sh    # Main script
├── reports/                 # Scan output directory
│   ├── scan_20250629_143022.txt
│   ├── scan_20250629_143022.xml
│   ├── scan_20250629_143022.html
│   └── scan_20250629_143022.gnmap
└── README.md

