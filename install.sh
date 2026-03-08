#!/bin/bash
set -euo pipefail

# Instalação automática com respostas pré-definidas

TOTVS_DIR="/totvs"
INSTALL_DIR="/totvs/licenseserver"

rm -rf "$INSTALL_DIR"

cd "$TOTVS_DIR"

echo "🚀 Iniciando instalação automática..."

# Envia respostas automáticas para o instalador
{
    echo ""               # TERMOS E CONDIÇÕES 1/3
    sleep 2
    echo ""               # TERMOS E CONDIÇÕES 2/3
    sleep 2
    echo ""               # TERMOS E CONDIÇÕES 3/3
    sleep 2
    echo "1"              # TERMOS E CONDIÇÕES | press 1 to accept, 2 to reject, 3 to redisplay
    sleep 2

    echo "$INSTALL_DIR"   # Diretório de instalação /totvs/licenseserver
    sleep 2

    echo "1"              # Enter para continuar
    sleep 2

    echo ""               # Enter para continuar
    sleep 2

    echo "1"              # Enter para continuar
    sleep 2

    echo ""               # Enter para continuar | TOTVS | License Server Virtual (Instalação do TOTVS | License Server Virtual.)
    sleep 2
    echo ""               # Enter para continuar | TOTVS | License Server Virtual - RPO (Instalação do TOTVS | License Server Virtual - RPO.)
    sleep 2
    echo ""               # Enter para continuar | TOTVS | License Server Virtual - Binarios (Instalação do TOTVS | License Server Virtual - Binarios.)
    sleep 2

    echo "1"              # Enter para continuar | press 1 to continue, 2 to quit, 3 to redisplay
    sleep 2

    echo ""               # Enter para continuar | null [2234]
    sleep 2

    echo ""               # Enter para continuar | null [4000]
    sleep 2

    echo ""               # Enter para continuar | null [5555]
    sleep 2

    echo ""               # Enter para continuar | null [licenseVirtual]
    sleep 2

    echo "1"              # Enter para continuar | press 1 to continue, 2 to quit, 3 to redisplay
    sleep 2

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
