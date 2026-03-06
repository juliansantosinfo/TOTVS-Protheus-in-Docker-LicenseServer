#!/bin/bash
set -euo pipefail

# Instalação automática com respostas pré-definidas

TOTVS_DIR="/totvs"
INSTALL_DIR="/totvs/licenseserver"

cd "$TOTVS_DIR"

echo "🚀 Iniciando instalação automática..."

# Envia respostas automáticas para o instalador
{
    echo "0"              # Select your language
    echo "1"              # Confirma
    echo "1"              # Acordo de licença
    echo "$INSTALL_DIR"   # Diretório de instalação
    echo "S"              # Enter para continuar
    echo "1"              # Confirma 
    echo "0"              # Instalação / Atualização
    echo "1"              # Confirma 
    echo "S"              # Include optional pack 'TOTVS | License Server Virtual'
    echo "1"              # Confirma 
    echo "1"              # Informações
    echo "2234"           # Porta de Monitoramento/Manutenção
    echo "4000"           # Porta do Serviço do Servidor de Log
    echo "5555"           # Porta do Serviço de Licenciamento. (conexão do ERP)
    echo "licenseVirtual" # Nome do serviço de Monitoramento/Manutenção
    echo "1"              # Confirma 
    echo ""               # Habilitar Proxy?
    echo "1"              # Confirma 
    echo "S"              # Confirma 
} | java -jar installer.jar

# Validação de retorno
IF_STATUS=$?
if [ $IF_STATUS -ne 0 ]; then
    echo "❌ O instalador Java retornou um erro (Código: $IF_STATUS)"
    exit 1
fi

# Validação de estrutura
pwd 
ls -l /totvs
if [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/bin/appserver/appsrvlinux" ]; then
    echo "✅ Diretórios criados com sucesso em $INSTALL_DIR"
else
    echo "❌ Erro: O diretório de instalação ou o executável não foram encontrados."
    exit 1
fi

echo "✅ Instalação concluída!"
