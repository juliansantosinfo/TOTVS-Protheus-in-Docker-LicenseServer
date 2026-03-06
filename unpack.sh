#!/usr/bin/env bash
#
# ==============================================================================
# SCRIPT:      unpack.sh
# DESCRIÇÃO:   Processa e descompacta pacotes de dependências do diretório 'packages'
#              para as pastas correspondentes no projeto TOTVS Protheus.
# AUTOR:       Julian de Almeida Santos
# DATA:        2026-02-28
# USO:         ./unpack.sh [appserver|webapp|rpo|helps|dictionaries|menus|all]
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 🛠️ CONFIGURAÇÕES E CAMINHOS
# ------------------------------------------------------------------------------

# Diretórios base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="${BASE_DIR}/packages"
TOTVS_DIR="${BASE_DIR}/totvs"
VERSIONS_FILE="${BASE_DIR}/versions.env"

# Cores para logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# 📢 FUNÇÕES DE LOG
# ------------------------------------------------------------------------------

log_info()    { echo -e "ℹ️  $1"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error()   { echo -e "${RED}❌ $1${NC}"; exit 1; }

# ------------------------------------------------------------------------------
# 🔍 VALIDAÇÕES INICIAIS
# ------------------------------------------------------------------------------

if [[ ! -f "$VERSIONS_FILE" ]]; then
    log_error "Arquivo de versões não encontrado em: $VERSIONS_FILE"
fi

# shellcheck source=/dev/null
source "$VERSIONS_FILE"

if [[ -z "${LICENSESERVER_VERSION:-}" ]]; then
    log_error "A variável 'LICENSESERVER_VERSION' não está definida no arquivo $VERSIONS_FILE"
fi

# ------------------------------------------------------------------------------
# 🚀 PROCESSAMENTO DO LICENSE SERVER BINARY (TAR.GZ + VALIDAÇÃO)
# ------------------------------------------------------------------------------

process_licenseserver() {
    echo "------------------------------------------------------------------------"
    log_info "Iniciando processamento do binário do License Server..."

    local found_file=""
    found_file=$(find "$PACKAGES_DIR" -maxdepth 1 -iname "*TOTVSLICENSE_*.TAR.GZ" -print -quit)

    if [[ -z "$found_file" ]]; then
        log_warn "Nenhum pacote de binário encontrado em '$PACKAGES_DIR' com 'TOTVSLICENSE_'. Pulando..."
        return
    fi

    local filename
    filename=$(basename "$found_file")
    
    local file_version
    file_version=$(echo "$filename" | sed -n 's/.*TOTVSLICENSE_\([0-9.]*\).*/\1/p')

    if [[ -z "$file_version" ]]; then
        log_error "Não foi possível extrair a versão do arquivo: $filename"
    fi

    log_info "Arquivo localizado: $filename"
    log_info "Versão detectada: $file_version"

    if [[ "$file_version" != "$LICENSESERVER_VERSION" ]]; then
        echo -e "${RED}🚨 ERRO: Versão do arquivo (${file_version}) diverge do versions.env (${LICENSESERVER_VERSION})${NC}"
        exit 1
    fi

    log_info "Descompactando para: $TOTVS_DIR..."
    mkdir -p "$TOTVS_DIR"
    tar -xzf "$found_file" -C "$TOTVS_DIR"
    
    log_success "Binário do License Server descompactado com sucesso!"
}

# ------------------------------------------------------------------------------
# 🏁 EXECUÇÃO PRINCIPAL
# ------------------------------------------------------------------------------

main() {
    
    log_info "🚀 Iniciando o script de descompactação de dependências..."
    
    process_licenseserver
    
    echo "------------------------------------------------------------------------"
    log_success "Processamento concluído!"
}

main "$@"
