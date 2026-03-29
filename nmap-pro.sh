#!/bin/bash

# ==============================
# NMAP PRO - by bhu01hackerspace
# ==============================

clear

# Cores
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Banner
echo -e "${CYAN}"
echo "███╗   ██╗███╗   ███╗ █████╗ ██████╗     ██████╗ ██████╗  ██████╗ "
echo "████╗  ██║████╗ ████║██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗"
echo "██╔██╗ ██║██╔████╔██║███████║██████╔╝    ██████╔╝██████╔╝██║   ██║"
echo "██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝     ██╔═══╝ ██╔══██╗██║   ██║"
echo "██║ ╚████║██║ ╚═╝ ██║██║  ██║██║         ██║     ██║  ██║╚██████╔╝"
echo "╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝         ╚═╝     ╚═╝  ╚═╝ ╚═════╝ "
echo -e "${NC}"

echo -e "${GREEN}NMAP PRO${NC}"
echo ""

# Entrada
read -p "Alvo (IP ou domínio): " target

# Menu
while true; do
echo ""
echo -e "${YELLOW}Escolha uma opção:${NC}"
echo "1) Scan rápido"
echo "2) Scan completo"
echo "3) Scan stealth (silencioso)"
echo "4) Descoberta de hosts"
echo "5) Detecção de serviços e versão"
echo "6) Detecção de SO"
echo "7) Scan com scripts NSE básicos"
echo "8) Scan vulnerabilidades"
echo "9) Scan agressivo (full power)"
echo "10) Scan portas específicas"
echo "11) Exportar resultados"
echo "0) Sair"
echo ""

read -p "Opção: " op

case $op in

1)
echo -e "${CYAN}Scan rápido...${NC}"
nmap -T4 -F $target
;;

2)
echo -e "${CYAN}Scan completo...${NC}"
nmap -p- -T4 $target
;;

3)
echo -e "${CYAN}Scan stealth (SYN)...${NC}"
sudo nmap -sS -T2 $target
;;

4)
echo -e "${CYAN}Descobrindo hosts...${NC}"
nmap -sn $target
;;

5)
echo -e "${CYAN}Detectando serviços...${NC}"
nmap -sV $target
;;

6)
echo -e "${CYAN}Detectando sistema operacional...${NC}"
sudo nmap -O $target
;;

7)
echo -e "${CYAN}Rodando scripts básicos...${NC}"
nmap -sC $target
;;

8)
echo -e "${RED}Buscando vulnerabilidades...${NC}"
nmap --script vuln $target
;;

9)
echo -e "${RED}Scan agressivo...${NC}"
sudo nmap -A -T4 $target
;;

10)
read -p "Digite portas (ex: 80,443,21): " portas
nmap -p $portas $target
;;

11)
echo -e "${GREEN}Salvando resultados...${NC}"
nmap -oN resultado.txt -oX resultado.xml -oG resultado.grep $target
echo "Salvo em resultado.*"
;;

0)
echo "Saindo..."
exit
;;

*)
echo "Opção inválida"
;;

esac

done
