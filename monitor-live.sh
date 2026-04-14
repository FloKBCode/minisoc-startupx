#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     STARTUPX — SURVEILLANCE SSH LIVE     ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  ${YELLOW}Surveillance en cours... (Ctrl+C pour arrêter)${NC}"
echo ""

sudo tail -f -n 0 /var/log/auth.log /var/log/fail2ban.log 2>/dev/null | while read line; do
    if echo "$line" | grep -q "Failed password"; then
        IP=$(echo "$line" | grep -oP '(\d+\.){3}\d+' | head -1)
        echo -e "  ${RED}[ALERTE]${NC} $(date '+%H:%M:%S') — Tentative échouée depuis ${RED}$IP${NC}"
    elif echo "$line" | grep -q "Accepted"; then
        IP=$(echo "$line" | grep -oP '(\d+\.){3}\d+' | head -1)
        echo -e "  ${GREEN}[OK]${NC} $(date '+%H:%M:%S') — Connexion réussie depuis ${GREEN}$IP${NC}"
    elif echo "$line" | grep -qE "Ban |banned"; then
        IP=$(echo "$line" | grep -oP '(\d+\.){3}\d+' | head -1)
        echo -e "  ${YELLOW}[BAN]${NC} $(date '+%H:%M:%S') — IP bannie : ${YELLOW}$IP${NC}"
    fi
done
