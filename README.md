# MiniSOC — StartupX

Infrastructure réseau segmentée avec détection d'intrusion en temps réel.

## Projet UF INFRA — Ynov Campus B1

**Équipe** : Florence Kore-Belle, Marly Dedjiho, Sarah Bouhadra

## Architecture
- Zone LAN : 192.168.100.0/24 (employés)
- Zone WAN : 10.0.0.0/24 (interface exposée)
- 3 VMs VirtualBox : srv-main (Ubuntu Server 24.04) + client-user (Ubuntu Desktop 24.04) + kali-attack (Kali Linux)

## Services déployés
- DHCP, DNS (bind9), Apache2, UFW, Fail2ban, Netdata, SSH

## Scripts
- `check-services.sh` — État des services en temps réel
- `rapport-incident.sh` — Rapport d'incident automatique
- `monitor-live.sh` — Surveillance SSH live

## Livrables
- Documentation technique complète
- Présentation PowerPoint
- Script oral
