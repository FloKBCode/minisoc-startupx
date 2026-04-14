#!/bin/bash

DATE=$(date '+%Y-%m-%d %H:%M:%S')
DATEFILE=$(date '+%Y%m%d-%H%M')
RAPPORT="/var/log/rapports/rapport-${DATEFILE}.txt"
sudo mkdir -p /var/log/rapports

{
echo "============================================================"
echo "   RAPPORT D'INCIDENT — StartupX Infrastructure"
echo "   Généré le : $DATE"
echo "   Serveur   : $(hostname)"
echo "============================================================"
echo ""

echo "[ STATUT DES SERVICES ]"
echo "-----------------------------------------------------------"
for service in apache2 isc-dhcp-server bind9 fail2ban ufw netdata ssh; do
    STATUS=$(systemctl is-active "$service" 2>/dev/null)
    if [ "$STATUS" = "active" ]; then
        echo "  OK  $service"
    else
        echo "  KO  $service — INACTIF"
    fi
done
echo ""

echo "[ INFORMATIONS SYSTÈME ]"
echo "-----------------------------------------------------------"
echo "  Uptime  : $(uptime -p)"
echo "  Charge  : $(uptime | awk -F'load average:' '{print $2}')"
echo "  Mémoire : $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
echo "  Disque  : $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
echo ""

echo "[ INTERFACES RÉSEAU ]"
echo "-----------------------------------------------------------"
echo "  LAN (enp0s8) : $(ip -4 addr show enp0s8 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')/24"
echo "  WAN (enp0s9) : $(ip -4 addr show enp0s9 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')/24"
echo ""

echo "[ IPs BANNIES PAR FAIL2BAN ]"
echo "-----------------------------------------------------------"
sudo fail2ban-client status sshd 2>/dev/null
echo ""

echo "[ DERNIÈRES TENTATIVES SSH ÉCHOUÉES (20 dernières) ]"
echo "-----------------------------------------------------------"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -20 || echo "  Aucune tentative enregistrée"
echo ""

echo "[ CONNEXIONS SSH RÉUSSIES ]"
echo "-----------------------------------------------------------"
sudo grep "Accepted" /var/log/auth.log 2>/dev/null | tail -10 || echo "  Aucune connexion enregistrée"
echo ""

echo "[ CONNEXIONS DHCP ACTIVES ]"
echo "-----------------------------------------------------------"
sudo cat /var/lib/dhcp/dhcpd.leases 2>/dev/null | grep "lease\|client-hostname\|binding" | head -30 || echo "  Aucun bail actif"
echo ""

echo "============================================================"
echo "   Fin du rapport — $DATE"
echo "============================================================"
} | tee "$RAPPORT"

echo ""
echo "Rapport sauvegardé : $RAPPORT"
