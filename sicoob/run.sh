#!/bin/bash

# Verifica se está rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script precisa ser executado com sudo ou como root."
  exit 1
fi

echo "🚀 Iniciando configuração do ambiente de desenvolvimento Sicoob..."

echo "🔄 Atualizando lista de pacotes (se necessário)..."
apt update -y && apt upgrade -y

# Lista de pacotes essenciais
PACOTES=(
  git
  curl
  wget
  unzip
  zip
  tar
  tree
  htop
  vim
  nano
  xclip
  build-essential
  python3-pip
  locales
  terminator
  sed
)

echo "📦 Verificando e instalando pacotes essenciais, se necessário..."
for pacote in "${PACOTES[@]}"; do
  if dpkg -s "$pacote" &>/dev/null; then
    echo "  ✅ $pacote já está instalado."
  else
    echo "  📥 Instalando $pacote..."
    apt install -y "$pacote"
  fi
done

# Diretório base do usuário que chamou o sudo
USER_HOME=$(eval echo "~$SUDO_USER")
DESTINO="$USER_HOME/Trabalho/Sicoob/Logistica/fonte"

echo "📁 Verificando existência do diretório $DESTINO..."
if [ -d "$DESTINO" ]; then
  echo "  ✅ Diretório já existe."
else
  echo "  📁 Criando diretório $DESTINO..."
  mkdir -p "$DESTINO"
fi

# Verificar se o dono está correto
OWNER=$(stat -c '%U' "$USER_HOME/Trabalho")
if [ "$OWNER" != "$SUDO_USER" ]; then
  echo "🔧 Ajustando permissões do diretório para o usuário '$SUDO_USER'..."
  chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/Trabalho"
else
  echo "  ✅ Permissões já estão corretas."
fi

# Define o Terminator como terminal padrão no Cinnamon
echo "🖥️ Definindo Terminator como terminal padrão do sistema..."
TERMINATOR_BIN="/usr/bin/terminator"
if command -v terminator &>/dev/null; then
  su - "$SUDO_USER" -c "gsettings set org.cinnamon.desktop.default-applications.terminal exec '$TERMINATOR_BIN'"
  su - "$SUDO_USER" -c "gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg '-x'"
  echo "  ✅ Terminator definido como terminal padrão."
else
  echo "  ⚠️ Terminator não encontrado. Pulei a configuração como terminal padrão."
fi

echo "🧹 Limpando cache do apt..."
apt clean

echo "✅ Ambiente básico configurado com sucesso!"