#!/bin/bash

# ============================================
# NMAP PRO - Scanner de Rede Profissional v2.0
# ============================================
# Autor: bhu01hackerspace
# Descrição: Ferramenta profissional para scanning de redes
# ============================================

clear

# ==================== CONFIGURAÇÕES ====================
VERSION="2.0"
LOG_DIR="$HOME/nmap_pro_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Cria diretório de logs se não existir
mkdir -p "$LOG_DIR"

# ==================== CORES ====================
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# ==================== FUNÇÕES ====================

# Função para exibir banner
banner() {
    echo -e "${CYAN}"
    echo "███╗   ██╗███╗   ███╗ █████╗ ██████╗     ██████╗ ██████╗  ██████╗ "
    echo "████╗  ██║████╗ ████║██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗"
    echo "██╔██╗ ██║██╔████╔██║███████║██████╔╝    ██████╔╝██████╔╝██║   ██║"
    echo "██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝     ██╔═══╝ ██╔══██╗██║   ██║"
    echo "██║ ╚████║██║ ╚═╝ ██║██║  ██║██║         ██║     ██║  ██║╚██████╔╝"
    echo "╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝         ╚═╝     ╚═╝  ╚═╝ ╚═════╝ "
    echo -e "${NC}"
    echo -e "${GREEN}${BOLD}Scanner de Rede Profissional v${VERSION}${NC}"
    echo -e "${YELLOW}Desenvolvido por bhu01hackerspace${NC}"
    echo "================================================"
    echo ""
}

# Função para validar IP/domínio
validar_alvo() {
    local alvo=$1
    # Valida IP (simples)
    if [[ $alvo =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    fi
    # Valida domínio (simples)
    if [[ $alvo =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    fi
    # Valida CIDR
    if [[ $alvo =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        return 0
    fi
    return 1
}

# Função para executar scan com salvamento
executar_scan() {
    local comando=$1
    local descricao=$2
    local nome_arquivo=$3
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ ${descricao}${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Arquivo de log
    LOG_FILE="${LOG_DIR}/${nome_arquivo}_${TIMESTAMP}.txt"
    
    # Executa comando
    if [[ $comando == *"sudo"* ]]; then
        echo -e "${RED}⚠️  Este scan requer privilégios root${NC}"
        echo -e "${CYAN}Será solicitada a senha do sudo...${NC}"
        echo ""
    fi
    
    echo -e "${CYAN}Executando: ${WHITE}$comando${NC}"
    echo ""
    
    # Executa e salva log
    eval "$comando" | tee "$LOG_FILE"
    
    echo ""
    echo -e "${GREEN}✓ Scan concluído!${NC}"
    echo -e "${GREEN}✓ Resultados salvos em: ${LOG_FILE}${NC}"
    echo ""
    
    # Pergunta se quer visualizar em formato organizado
    read -p "$(echo -e ${YELLOW}"Deseja visualizar os resultados em formato resumido? (s/N): "${NC})" ver_resumo
    if [[ $ver_resumo =~ ^[Ss]$ ]]; then
        echo ""
        echo -e "${CYAN}━━━━ RESUMO DO SCAN ━━━━${NC}"
        grep -E "^(PORT|Nmap|Interesting|Not shown|MAC|OS|Service|TRACEROUTE|Host)" "$LOG_FILE" | grep -v "ms$" | head -30
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
}

# Função para exportar resultados
exportar_resultados() {
    local arquivo_base="${LOG_DIR}/resultado_${TIMESTAMP}"
    
    echo -e "${YELLOW}Exportando resultados...${NC}"
    echo ""
    
    # Exporta para diferentes formatos
    nmap -oN "${arquivo_base}.nmap" -oX "${arquivo_base}.xml" -oG "${arquivo_base}.grep" $target
    
    echo -e "${GREEN}✓ Resultados exportados:${NC}"
    echo -e "  • Formato Nmap: ${arquivo_base}.nmap"
    echo -e "  • Formato XML: ${arquivo_base}.xml"
    echo -e "  • Formato Grepable: ${arquivo_base}.grep"
    echo ""
    
    # Pergunta se quer converter XML para HTML
    read -p "$(echo -e ${YELLOW}"Deseja gerar relatório HTML? (s/N): "${NC})" gerar_html
    if [[ $gerar_html =~ ^[Ss]$ ]]; then
        if command -v xsltproc &> /dev/null; then
            xsltproc "${arquivo_base}.xml" -o "${arquivo_base}.html"
            echo -e "${GREEN}✓ Relatório HTML gerado: ${arquivo_base}.html${NC}"
        else
            echo -e "${RED}✗ xsltproc não encontrado. Instale com: sudo apt install xsltproc${NC}"
        fi
    fi
}

# Função para scan personalizado
scan_portas_especificas() {
    echo -e "${CYAN}Opções de scan personalizado:${NC}"
    echo ""
    echo "1) Portas comuns (web, ssh, ftp, database)"
    echo "2) Portas específicas (digitar manualmente)"
    echo "3) Range de portas (ex: 1-1000)"
    echo "4) Portas web (80,443,8080,8443)"
    echo ""
    read -p "Escolha: " tipo_portas
    
    case $tipo_portas in
        1)
            portas="21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080,8443"
            descricao="Portas comuns"
            ;;
        2)
            read -p "Digite as portas (ex: 80,443,22): " portas
            descricao="Portas: $portas"
            ;;
        3)
            read -p "Digite o range (ex: 1-1000): " portas
            descricao="Range de portas: $portas"
            ;;
        4)
            portas="80,443,8080,8443"
            descricao="Portas web"
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            return 1
            ;;
    esac
    
    read -p "$(echo -e ${YELLOW}"Deseja detectar versões dos serviços? (s/N): "${NC})" detectar_versao
    if [[ $detectar_versao =~ ^[Ss]$ ]]; then
        executar_scan "nmap -p $portas -sV -T4 $target" "Scan de $descricao com detecção de versão" "portas_especificas"
    else
        executar_scan "nmap -p $portas -T4 $target" "Scan de $descricao" "portas_especificas"
    fi
}

# Função para scan de vulnerabilidades avançado
scan_vulnerabilidades_avancado() {
    echo -e "${RED}⚠️  ATENÇÃO: Scan de vulnerabilidades pode ser detectado como intrusivo!${NC}"
    echo ""
    echo "Selecione o tipo:"
    echo "1) Básico (scripts padrão)"
    echo "2) Completo (todos scripts vuln)"
    echo "3) Focado em serviços específicos"
    echo ""
    read -p "Opção: " tipo_vuln
    
    case $tipo_vuln in
        1)
            executar_scan "nmap --script vuln $target" "Scan de vulnerabilidades básico" "vuln_basico"
            ;;
        2)
            executar_scan "sudo nmap --script vuln -sV --script-args mincvss=5.0 $target" "Scan de vulnerabilidades completo" "vuln_completo"
            ;;
        3)
            read -p "Digite o serviço alvo (ex: http, ssh, mysql): " servico
            executar_scan "nmap --script vuln -p $(nmap -p- -T4 $target | grep open | cut -d'/' -f1 | tr '\n' ',') --script-args mincvss=5.0 $target" "Scan focado em $servico" "vuln_$servico"
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            ;;
    esac
}

# Função para descobrir hosts na rede
descobrir_hosts() {
    echo -e "${CYAN}Métodos de descoberta:${NC}"
    echo "1) Ping sweep (rápido)"
    echo "2) ARP scan (mais preciso em rede local)"
    echo "3) Descoberta de serviços UDP"
    echo ""
    read -p "Escolha: " metodo
    
    case $metodo in
        1)
            executar_scan "nmap -sn -T4 $target" "Descoberta de hosts via ICMP" "host_discovery"
            ;;
        2)
            executar_scan "sudo nmap -sn -PR $target" "Descoberta ARP" "arp_scan"
            ;;
        3)
            executar_scan "sudo nmap -sU --top-ports 20 $target" "Scan UDP rápido" "udp_scan"
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            ;;
    esac
}

# ==================== INÍCIO DO PROGRAMA ====================

banner

# Verifica se nmap está instalado
if ! command -v nmap &> /dev/null; then
    echo -e "${RED}❌ Erro: Nmap não está instalado!${NC}"
    echo -e "${YELLOW}Instale com: sudo apt install nmap${NC}"
    exit 1
fi

# Entrada do alvo
while true; do
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -p "🎯 Alvo (IP, domínio ou CIDR): " target
    
    if [[ -z "$target" ]]; then
        echo -e "${RED}❌ Alvo não pode estar vazio!${NC}"
    elif validar_alvo "$target"; then
        echo -e "${GREEN}✅ Alvo válido: $target${NC}"
        break
    else
        echo -e "${RED}❌ Formato inválido! Exemplos válidos:${NC}"
        echo "   • 192.168.1.1"
        echo "   • google.com"
        echo "   • 192.168.1.0/24"
    fi
done

# Menu principal
while true; do
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📋 MENU PRINCIPAL - ALVO: ${WHITE}$target${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}[ SCAN RÁPIDO ]${NC}"
    echo " 1) Scan rápido          - Portas comuns (top 100)"
    echo " 2) Scan completo        - Todas as 65535 portas"
    echo ""
    echo -e "${YELLOW}[ SCAN AVANÇADO ]${NC}"
    echo " 3) Scan stealth         - SYN scan (furtivo)"
    echo " 4) Detecção de serviços - Versões e banners"
    echo " 5) Detecção de SO       - Sistema operacional"
    echo " 6) Scan agressivo       - Full scan (A, T4)"
    echo ""
    echo -e "${YELLOW}[ DESCOBERTA ]${NC}"
    echo " 7) Descoberta de hosts  - Hosts ativos na rede"
    echo " 8) Scan UDP             - Serviços UDP"
    echo ""
    echo -e "${YELLOW}[ SEGURANÇA ]${NC}"
    echo " 9) Scripts NSE básicos  - Enumeração padrão"
    echo "10) Vulnerabilidades     - Scan de CVEs e exploits"
    echo ""
    echo -e "${YELLOW}[ PERSONALIZADO ]${NC}"
    echo "11) Portas específicas   - Escolha as portas"
    echo "12) Scan com timing      - Ajuste de velocidade"
    echo ""
    echo -e "${YELLOW}[ UTILITÁRIOS ]${NC}"
    echo "13) Exportar resultados  - Salvar em múltiplos formatos"
    echo "14) Ver logs anteriores  - Histórico de scans"
    echo ""
    echo -e "${RED} 0) Sair${NC}"
    echo ""
    
    read -p "👉 Opção: " op
    
    case $op in
    
    1)
        executar_scan "nmap -T4 -F $target" "Scan rápido (top 100 portas)" "scan_rapido"
        ;;
    
    2)
        executar_scan "nmap -p- -T4 -v $target" "Scan completo (todas portas)" "scan_completo"
        ;;
    
    3)
        executar_scan "sudo nmap -sS -T2 -v $target" "Scan stealth (SYN)" "scan_stealth"
        ;;
    
    4)
        read -p "$(echo -e ${YELLOW}"Scan agressivo de versões? (s/N): "${NC})" agressivo
        if [[ $agressivo =~ ^[Ss]$ ]]; then
            executar_scan "nmap -sV --version-intensity 9 -T4 $target" "Detecção de serviços (agressivo)" "services_detailed"
        else
            executar_scan "nmap -sV -T4 $target" "Detecção de serviços" "services"
        fi
        ;;
    
    5)
        executar_scan "sudo nmap -O -v $target" "Detecção de sistema operacional" "os_detection"
        ;;
    
    6)
        echo -e "${RED}⚠️  Scan agressivo pode ser barrado por firewalls!${NC}"
        read -p "$(echo -e ${YELLOW}"Confirmar execução? (s/N): "${NC})" confirmar
        if [[ $confirmar =~ ^[Ss]$ ]]; then
            executar_scan "sudo nmap -A -T4 -v $target" "Scan agressivo (OS, serviços, scripts)" "scan_agressivo"
        fi
        ;;
    
    7)
        descobrir_hosts
        ;;
    
    8)
        executar_scan "sudo nmap -sU --top-ports 100 -T4 $target" "Scan UDP (top 100 portas)" "udp_scan"
        ;;
    
    9)
        executar_scan "nmap -sC -T4 $target" "Scripts NSE padrão" "nse_basico"
        ;;
    
    10)
        scan_vulnerabilidades_avancado
        ;;
    
    11)
        scan_portas_especificas
        ;;
    
    12)
        echo -e "${CYAN}Escolha o timing (0-5):${NC}"
        echo "0) Paranóico (muito lento)"
        echo "1) Sorrateiro"
        echo "2) Educado"
        echo "3) Normal"
        echo "4) Agressivo"
        echo "5) Insano (rápido, mas pode perder dados)"
        read -p "Timing: " timing
        if [[ $timing =~ ^[0-5]$ ]]; then
            executar_scan "nmap -T$timing -v $target" "Scan com timing T$timing" "scan_t$timing"
        else
            echo -e "${RED}Opção inválida!${NC}"
        fi
        ;;
    
    13)
        exportar_resultados
        ;;
    
    14)
        echo -e "${CYAN}━━━━ LOGS ANTERIORES ━━━━${NC}"
        ls -lh "$LOG_DIR"/*.txt 2>/dev/null || echo -e "${YELLOW}Nenhum log encontrado.${NC}"
        echo ""
        read -p "$(echo -e ${YELLOW}"Deseja visualizar algum log? (digite o nome ou N): "${NC})" ver_log
        if [[ $ver_log != "N" && $ver_log != "n" && -f "$LOG_DIR/$ver_log" ]]; then
            less "$LOG_DIR/$ver_log"
        fi
        ;;
    
    0)
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}✨ Scanner encerrado. Obrigado por usar!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 0
        ;;
    
    *)
        echo -e "${RED}❌ Opção inválida! Tente novamente.${NC}"
        ;;
    
    esac
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Pressione ENTER para continuar..."${NC})" continuar
    
done
