# Dockerização do License Server para ERP TOTVS Protheus

## Overview

Este projeto contém a implementação do container Docker para o **License Server** da TOTVS.

A imagem é projetada para rodar sobre distribuições **Enterprise Linux** (como **Red Hat UBI** ou **Oracle Linux**), oferecendo segurança e estabilidade corporativa.

Este serviço é um componente essencial da arquitetura, responsável pelo gerenciamento, controle de concorrência e distribuição de licenças para os serviços de aplicação do Protheus.

### Diferenciais desta Imagem

*   **Segurança:** Base empresarial minimalista e otimizada.

### Outros Componentes Necessários

*   **Banco de Dados**: `mssql`, `postgres` ou `oracle`.
*   **dbaccess**: Middleware de acesso ao banco.
*   **appserver**: O servidor de aplicação Protheus.

## Início Rápido

**Importante:** Este contêiner precisa estar na mesma rede Docker que os outros serviços para que a comunicação funcione.

1.  **Baixe a imagem (se disponível no Docker Hub):**
    ```bash
    docker pull juliansantosinfo/totvs_licenseserver:latest
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**
    ```bash
    docker run -d \
      --name totvs_licenseserver \
      --network totvs \
      -p 5555:5555 \
      -p 2234:2234 \
      -p 8020:8020 \
      --ulimit nofile=65536:65536 \
      juliansantosinfo/totvs_licenseserver:latest
    ```

## Build Local

Caso queira construir a imagem localmente:

### 1. Preparar Pacotes

Baixe o binário do DbAccess e coloque nos diretório `packages/`:

```txt
packages/
├── 25-08-18-TOTVSLICENSE_3.6.1_LINUX.TAR.GZ
```

**Arquivos necessários:**
- **DbAccess Binary** - `*TOTVSLICENSE*.TAR.GZ`

### 2. Extrair Pacotes

Execute o script `unpack.sh` para extrair os pacotes para a estrutura correta:

```bash
./unpack.sh
```

Isso criará a seguinte estrutura:

```txt
totvs/
├── install
├── installer.jar
├── license.png
├── licenseserver
└── resources
    └── appserver.ini
```

### 3. Executar Build

Execute o script de build:

```bash
./build.sh
```

### Opções de Build

O script `build.sh` suporta várias opções:

```bash
./build.sh [OPTIONS]
```

**Opções disponíveis:**
- `--progress=<MODE>` - Define o modo de progresso (auto|plain|tty) [padrão: auto]
- `--no-cache` - Desabilita o cache do Docker
- `--no-extract` - Desabilita compressão de recursos no build
- `--build-arg KEY=VALUE` - Passa argumentos adicionais para o Docker build
- `--tag=<TAG>` - Define uma tag customizada para a imagem
- `-h, --help` - Exibe ajuda

**Exemplos:**
```bash
# Build padrão
./build.sh

# Build sem cache com progresso detalhado
./build.sh --progress=plain --no-cache

# Build com imagem base customizada
./build.sh --build-arg IMAGE_BASE=custom:tag

# Build com tag customizada
./build.sh --tag=myuser/appserver:1.0
```

### Build com Imagem Base Customizada

Quando usando uma imagem base customizada que já contém os recursos do Protheus (via `IMAGE_BASE` no `versions.env`), o script automaticamente pula a validação de diretórios locais:

```bash
# No GitHub Actions, IMAGE_BASE é carregado automaticamente
# Para build local com imagem customizada:
export IMAGE_BASE=juliansantosinfo/imagebase:totvs-licenseserver-build_3.6.1
./build.sh
```

## Push para Registry

Para enviar a imagem para o Docker Hub:

```bash
./push.sh [OPTIONS]
```

**Opções disponíveis:**
- `--no-latest` - Não faz push da tag 'latest'
- `--tag=<TAG>` - Define uma tag customizada para push
- `-h, --help` - Exibe ajuda

**Comportamento:**
- A tag `latest` só é enviada quando em branches `main` ou `master`
- Em outras branches, apenas a tag versionada é enviada

**Exemplos:**
```bash
# Push padrão (versão + latest se em main/master)
./push.sh

# Push apenas da versão (sem latest)
./push.sh --no-latest

# Push de tag customizada
./push.sh --tag=myuser/appserver:custom
```

## CI/CD com GitHub Actions

O projeto inclui workflow automatizado em `.github/workflows/deploy.yml` que:

1. **Detecta mudanças relevantes** - Ignora alterações em documentação e configurações
2. **Carrega imagem base customizada** - Usa `IMAGE_BASE` do `versions.env`
3. **Build automatizado** - Executa `./build.sh` com detecção de ambiente
4. **Push condicional** - Envia `latest` apenas em branches principais

**Configuração necessária:**

Adicione os secrets no repositório GitHub:
- `DOCKER_USERNAME` - Usuário do Docker Hub
- `DOCKER_TOKEN` - Token de acesso do Docker Hub

**Triggers:**
- Push em branches: `master`, `main`, `24.*`, `25.*`
- Pull requests para essas branches
- Execução manual via `workflow_dispatch`

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `LICENSE_TCP_PORT` | Porta TCP de comunicação. | `2234` |
| `LICENSE_PORT` | Porta principal do serviço. | `5555` |
| `LICENSE_WEBAPP_PORT`| Porta da interface web de monitoramento. | `8020` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração dos scripts (`true`/`false`). | `false` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
