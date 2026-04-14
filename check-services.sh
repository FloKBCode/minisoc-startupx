#!/bin/bash

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${BOLD}${CYAN}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║       STARTUPX — STATUS INFRASTRUCTURE   ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  ${BLUE}Date :${NC} $(date '+%d/%m/%Y %H:%M:%S')"
echo -e "  ${BLUE}Serveur :${NC} $(hostname) — LAN: 192.168.100.2 — WAN: 10.0.0.2"
echo ""
echo -e "  ${BOLD}── SERVICES ──────────────────────────────────${NC}"
echo ""

SERVICES=(
    "apache2:Serveur Web Apache"
    "isc-dhcp-server:Serveur DHCP"
    "bind9:Serveur DNS"
    "fail2ban:Détection intrusion"
    "ufw:Pare-feu UFW"
    "netdata:Monitoring Netdata"
    "ssh:Serveur SSH"
)

OK=0
KO=0

for entry in "${SERVICES[@]}"; do
    name="${entry%%:*}"
    label="${entry##*:}"
    STATUS=$(systemctl is-active "$name" 2>/dev/null)
    if [ "$STATUS" = "active" ]; then
        echo -e "  ${GREEN}✔${NC}  ${label} ${CYAN}(${name})${NC}"
        ((OK++))
    else
        echo -e "  ${RED}✘${NC}  ${label} ${CYAN}(${name})${NC} ${RED}— INACTIF${NC}"
        ((KO++))
    fi
done

echo ""
echo -e "  ${BOLD}── RÉSEAU ────────────────────────────────────${NC}"
echo ""
echo -e "  ${BLUE}LAN (enp0s8) :${NC} $(ip -4 addr show enp0s8 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
echo -e "  ${BLUE}WAN (enp0s9) :${NC} $(ip -4 addr show enp0s9 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
echo -e "  ${BLUE}NAT (enp0s3) :${NC} $(ip -4 addr show enp0s3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"

echo ""
echo -e "  ${BOLD}── SYSTÈME ───────────────────────────────────${NC}"
echo ""
echo -e "  ${BLUE}Uptime :${NC} $(uptime -p)"
echo -e "  ${BLUE}Charge :${NC} $(uptime | awk -F'load average:' '{print $2}')"
echo -e "  ${BLUE}Mémoire :${NC} $(free -h | awk '/^Mem:/ {print $3 " utilisés / " $2 " total"}')"
echo -e "  ${BLUE}Disque :${NC} $(df -h / | awk 'NR==2 {print $3 " utilisés / " $2 " total (" $5 ")"}')"

echo ""
echo -e "  ${BOLD}── IPs BANNIES (Fail2ban) ────────────────────${NC}"
echo ""
BANNED=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Banned IP" | awk -F: '{print $2}')
if [ -z "$BANNED" ] || [ "$BANNED" = " " ]; then
    echo -e "  ${GREEN}Aucune IP bannie actuellement${NC}"
else
    echo -e "  ${RED}IPs bannies :${NC} $BANNED"
fi

echo ""
echo -e "  ${BOLD}── RÉSUMÉ ────────────────────────────────────${NC}"
echo ""
if [ $KO -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}✔ Tous les services sont opérationnels ($OK/$((OK+KO)))${NC}"
else
    echo -e "  ${RED}${BOLD}✘ $KO service(s) en erreur — $OK/$((OK+KO)) opérationnels${NC}"
fi
echo ""
echo -e "  ${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo ""
