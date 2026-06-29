#!/bin/bash

# =============================================================================
#  TECH INTELLIGENCE SCANNER v2.0 — Interactive Edition
#  Step-by-step network reconnaissance for authorized penetration testing
# =============================================================================

set -euo pipefail

# ----- Colors -----
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ----- Global -----
REPORT_DIR="reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# ----- Check dependencies -----
check_deps() {
    if ! command -v nmap &>/dev/null; then
        echo -e "${RED}[!] Nmap is not installed.${NC}"
        echo -e "Install: ${YELLOW}sudo apt install nmap${NC}"
        exit 1
    fi
}

# ----- Animated spinner -----
spinner() {
    local pid=$1
    local msg="$2"
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${CYAN}[%c]${NC} %s ..." "${spin:$i:1}" "$msg"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.1
    done
    printf "\r${GREEN}[✓]${NC} %s     \n" "$msg"
}

# ----- Print banner -----
print_banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"
████████╗███████╗ ██████╗██╗  ██╗
╚══██╔══╝██╔════╝██╔════╝██║  ██║
   ██║   █████╗  ██║     ███████║
   ██║   ██╔══╝  ██║     ██╔══██║
   ██║   ███████╗╚██████╗██║  ██║
   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝
EOF
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}      TECH INTELLIGENCE SCANNER v2.0${NC}"
    echo -e "${BLUE}       Interactive Network Reconnaissance${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo ""
}

# ----- Step 1: Get target -----
get_target() {
    echo -e "${YELLOW}STEP 1: Target Selection${NC}"
    echo -e "${DIM}──────────────────────────────────────────────${NC}"
    echo -e "Enter target ${BOLD}IP address${NC}, ${BOLD}domain${NC}, or ${BOLD}CIDR range${NC}."
    echo -e "Examples: ${GREEN}10.10.10.1${NC}, ${GREEN}scanme.nmap.org${NC}, ${GREEN}192.168.1.0/24${NC}"
    echo ""
    
    while true; do
        read -r -p "$(echo -e "${BOLD}Target:${NC} ")" TARGET
        if [[ -z "$TARGET" ]]; then
            echo -e "${RED}[!] Target cannot be empty.${NC}"
        else
            break
        fi
    done
    
    echo ""
}

# ----- Step 2: Select scan mode -----
get_scan_mode() {
    echo -e "${YELLOW}STEP 2: Select Scan Type${NC}"
    echo -e "${DIM}──────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}1)${NC} ${GREEN}Ping Sweep${NC}       — Discover live hosts only"
    echo -e "  ${BOLD}2)${NC} ${GREEN}Quick Scan${NC}        — Top 100 ports + service detection"
    echo -e "  ${BOLD}3)${NC} ${GREEN}Standard Scan${NC}     — SYN scan + versions + default scripts"
    echo -e "  ${BOLD}4)${NC} ${GREEN}Comprehensive${NC}     — Full ports + OS + scripts + traceroute"
    echo -e "  ${BOLD}5)${NC} ${GREEN}Vulnerability Audit${NC} — Run all NSE vulnerability scripts"
    echo -e "  ${BOLD}6)${NC} ${GREEN}Stealth Scan${NC}      — Decoys, slow rate, no ping"
    echo -e "  ${BOLD}7)${NC} ${GREEN}Full Scan${NC}         — Aggressive: all ports + everything"
    echo -e "  ${BOLD}8)${NC} ${GREEN}Custom Scan${NC}       — Manually enter Nmap arguments"
    echo ""
    
    while true; do
        read -r -p "$(echo -e "${BOLD}Choice [1-8]:${NC} ")" SCAN_CHOICE
        case "$SCAN_CHOICE" in
            1) SCAN="-sn"; MODE_LABEL="Ping Sweep"; break ;;
            2) SCAN="-sS -sV --top-ports 100"; MODE_LABEL="Quick Scan"; break ;;
            3) SCAN="-sS -sV -sC"; MODE_LABEL="Standard Scan"; break ;;
            4) SCAN="-sS -sV -O -sC --traceroute -p-"; MODE_LABEL="Comprehensive"; break ;;
            5) SCAN="-sS -sV --script vuln"; MODE_LABEL="Vulnerability Audit"; break ;;
            6) SCAN="-sS -sV -O -sC -Pn -D RND:10 -T2 --max-retries 1 --min-rate 50"; MODE_LABEL="Stealth Scan"; break ;;
            7) SCAN="-Pn -p- -sS -sV -O -sC --traceroute"; MODE_LABEL="Full Scan"; break ;;
            8) read -r -p "$(echo -e "${YELLOW}Enter raw Nmap flags:${NC} ")" SCAN
               MODE_LABEL="Custom"
               break ;;
            *) echo -e "${RED}[!] Invalid option. Select 1-8.${NC}" ;;
        esac
    done
    
    echo ""
}

# ----- Step 3: Timing template -----
get_timing() {
    echo -e "${YELLOW}STEP 3: Scan Speed (Timing Template)${NC}"
    echo -e "${DIM}──────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}0)${NC} ${MAGENTA}Paranoid${NC}       — Extremely slow, IDS evasion"
    echo -e "  ${BOLD}1)${NC} ${MAGENTA}Sneaky${NC}         — Very slow, quiet"
    echo -e "  ${BOLD}2)${NC} ${MAGENTA}Polite${NC}         — Slower, less bandwidth"
    echo -e "  ${BOLD}3)${NC} ${GREEN}Normal${NC}           — Default speed"
    echo -e "  ${BOLD}4)${NC} ${GREEN}Aggressive${NC}       — Faster, reasonable networks"
    echo -e "  ${BOLD}5)${NC} ${RED}Insane${NC}            — Very fast, may miss ports"
    echo -e "  ${BOLD}6)${NC} ${YELLOW}Skip${NC}            — Use Nmap default"
    echo ""
    
    while true; do
        read -r -p "$(echo -e "${BOLD}Choice [0-6]:${NC} ")" TIMING
        case "$TIMING" in
            0|1|2|3|4|5) TIMING="-T$TIMING"; break ;;
            6) TIMING=""; break ;;
            *) echo -e "${RED}[!] Invalid option. Select 0-6.${NC}" ;;
        esac
    done
    
    echo ""
}

# ----- Step 4: Port selection -----
get_ports() {
    echo -e "${YELLOW}STEP 4: Port Selection${NC}"
    echo -e "${DIM}──────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}1)${NC} ${GREEN}Use default${NC}      — Let scan mode decide"
    echo -e "  ${BOLD}2)${NC} ${GREEN}Specify ports${NC}    — e.g. ${CYAN}22,80,443${NC} or ${CYAN}1-1000${NC}"
    echo -e "  ${BOLD}3)${NC} ${GREEN}All ports${NC}        — 1-65535 (slow but thorough)"
    echo ""
    
    while true; do
        read -r -p "$(echo -e "${BOLD}Choice [1-3]:${NC} ")" PORT_CHOICE
        case "$PORT_CHOICE" in
            1) PORTS=""; break ;;
            2) read -r -p "$(echo -e "${YELLOW}Enter port(s):${NC} ")" PORTS
               PORTS="-p $PORTS"
               break ;;
            3) PORTS="-p-"; break ;;
            *) echo -e "${RED}[!] Invalid option.${NC}" ;;
        esac
    done
    
    echo ""
}

# ----- Step 5: Output format -----
get_output_format() {
    echo -e "${YELLOW}STEP 5: Report Format${NC}"
    echo -e "${DIM}──────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}1)${NC} ${GREEN}TXT${NC}     — Plain text (human readable)"
    echo -e "  ${BOLD}2)${NC} ${GREEN}XML${NC}     — Machine-readable"
    echo -e "  ${BOLD}3)${NC} ${GREEN}HTML${NC}    — Web report (requires xsltproc)"
    echo -e "  ${BOLD}4)${NC} ${GREEN}All${NC}     — Generate TXT + XML + HTML + grepable"
    echo ""
    
    while true; do
        read -r -p "$(echo -e "${BOLD}Choice [1-4]:${NC} ")" FORMAT_CHOICE
        case "$FORMAT_CHOICE" in
            1) FORMAT="txt"; break ;;
            2) FORMAT="xml"; break ;;
            3) FORMAT="html"; break ;;
            4) FORMAT="all"; break ;;
            *) echo -e "${RED}[!] Invalid option.${NC}" ;;
        esac
    done
    
    echo ""
}

# ----- Step 6: Confirmation -----
confirm_scan() {
    echo -e "${YELLOW}STEP 6: Review & Confirm${NC}"
    echo -e "${DIM}──────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}Target:${NC}      ${GREEN}$TARGET${NC}"
    echo -e "  ${BOLD}Scan Mode:${NC}   ${GREEN}$MODE_LABEL${NC}"
    echo -e "  ${BOLD}Timing:${NC}      ${GREEN}${TIMING:--T4 (default)}${NC}"
    echo -e "  ${BOLD}Ports:${NC}       ${GREEN}${PORTS:-Mode default}${NC}"
    echo -e "  ${BOLD}Format:${NC}      ${GREEN}$FORMAT${NC}"
    echo ""
    
    read -r -p "$(echo -e "${BOLD}Start scan? [Y/n]:${NC} ")" CONFIRM
    if [[ "$CONFIRM" =~ ^[Nn] ]]; then
        echo -e "${YELLOW}[!] Scan cancelled.${NC}"
        exit 0
    fi
    echo ""
}

# ----- Build final command -----
build_command() {
    local base="reports/scan_${TIMESTAMP}"
    CMD="nmap ${TIMING:- -T4}"
    
    if [[ -n "$PORTS" ]]; then
        CMD="$CMD $PORTS"
    fi
    
    CMD="$CMD $SCAN --open $TARGET"
    
    # Output flag
    case "$FORMAT" in
        txt)  CMD="$CMD -oN ${base}.txt" ;;
        xml)  CMD="$CMD -oX ${base}.xml" ;;
        html) CMD="$CMD -oX ${base}.xml" ;;
        all)  CMD="$CMD -oA $base" ;;
    esac
}

# ----- Execute the scan -----
run_scan() {
    local base="reports/scan_${TIMESTAMP}"
    
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}[*] Executing:${NC} $CMD"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}[*] Scanning $TARGET ...${NC}"
    echo ""
    
    mkdir -p reports
    
    case "$FORMAT" in
        txt)
            nmap ${TIMING:- -T4} ${PORTS:-} $SCAN --open "$TARGET" -oN "${base}.txt"
            echo -e "\n${GREEN}[✓] Report saved: ${base}.txt${NC}"
            ;;
        xml)
            nmap ${TIMING:- -T4} ${PORTS:-} $SCAN --open "$TARGET" -oX "${base}.xml"
            echo -e "\n${GREEN}[✓] Report saved: ${base}.xml${NC}"
            ;;
        html)
            nmap ${TIMING:- -T4} ${PORTS:-} $SCAN --open "$TARGET" -oX "${base}.xml"
            if command -v xsltproc &>/dev/null; then
                xsltproc "${base}.xml" -o "${base}.html" 2>/dev/null
                echo -e "\n${GREEN}[✓] HTML report: ${base}.html${NC}"
            else
                echo -e "\n${YELLOW}[!] xsltproc not found. Install: sudo apt install xsltproc${NC}"
                echo -e "${GREEN}[✓] XML saved: ${base}.xml${NC}"
            fi
            ;;
        all)
            nmap ${TIMING:- -T4} ${PORTS:-} $SCAN --open "$TARGET" -oA "$base"
            if command -v xsltproc &>/dev/null && [[ -f "${base}.xml" ]]; then
                xsltproc "${base}.xml" -o "${base}.html" 2>/dev/null
            fi
            echo -e "\n${GREEN}[✓] Reports saved:${NC}"
            echo -e "  ${base}.txt  (plain text)"
            echo -e "  ${base}.xml  (XML)"
            echo -e "  ${base}.gnmap (grepable)"
            [[ -f "${base}.html" ]] && echo -e "  ${base}.html (HTML)"
            ;;
    esac
}

# ----- Completion message -----
print_complete() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}  ✓ Scan completed successfully!${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${DIM}Target:${NC} $TARGET"
    echo -e "${DIM}Mode:${NC}   $MODE_LABEL"
    echo -e "${DIM}Date:${NC}   $(date)"
    echo ""
    echo -e "${YELLOW}Output directory: ${BOLD}$REPORT_DIR/${NC}"
    echo ""
}

# ----- Menu for running multiple scans or exiting -----
end_menu() {
    echo ""
    echo -e "${YELLOW}What would you like to do?${NC}"
    echo ""
    echo -e "  ${BOLD}1)${NC} ${GREEN}Run another scan${NC}"
    echo -e "  ${BOLD}2)${NC} ${GREEN}Exit${NC}"
    echo ""
    
    while true; do
        read -r -p "$(echo -e "${BOLD}Choice [1-2]:${NC} ")" AGAIN
        case "$AGAIN" in
            1) return 0 ;;
            2) echo -e "\n${GREEN}Goodbye. Stay sharp.${NC}"; exit 0 ;;
            *) echo -e "${RED}[!] Invalid option.${NC}" ;;
        esac
    done
}

# ===== MAIN =====
check_deps

while true; do
    print_banner
    get_target
    get_scan_mode
    get_timing
    get_ports
    get_output_format
    confirm_scan
    build_command
    run_scan
    print_complete
    end_menu
done
