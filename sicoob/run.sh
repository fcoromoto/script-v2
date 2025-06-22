#!/bin/bash

# Verifica se está rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script precisa ser executado com sudo ou como root."
  exit 1
fi

echo "🚀 Iniciando configuração do ambiente de desenvolvimento Sicoob..."

echo "🔄 Atualizando lista de pacotes..."
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
  zsh
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

# Ajustando permissões
OWNER=$(stat -c '%U' "$USER_HOME/Trabalho")
if [ "$OWNER" != "$SUDO_USER" ]; then
  echo "🔧 Ajustando permissões do diretório para o usuário '$SUDO_USER'..."
  chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/Trabalho"
else
  echo "  ✅ Permissões já estão corretas."
fi

# Instalação e configuração do ZSH com tema Agnoster
echo "🧠 Instalando e configurando ZSH com Oh My Zsh + tema Agnoster..."

su - "$SUDO_USER" -c '
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "  📥 Instalando Oh My Zsh..."
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "  ✅ Oh My Zsh já está instalado."
  fi

  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

  echo "  🔌 Instalando plugins zsh-autosuggestions e zsh-syntax-highlighting..."
  [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

  echo "  🎨 Configurando tema para 'agnoster'..."
  sed -i "s|^ZSH_THEME=.*|ZSH_THEME=\"agnoster\"|" "$HOME/.zshrc"

  echo "  ⚙️ Configurando plugins no .zshrc..."
  sed -i "s|^plugins=(.*)|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|" "$HOME/.zshrc"

  echo "  ✅ ZSH com tema Agnoster e plugins configurado com sucesso."
'

echo "🔁 Alterando shell padrão para Zsh (usuário $SUDO_USER)..."
chsh -s "$(which zsh)" "$SUDO_USER"

# Mapeia Ctrl+Alt+T diretamente para Terminator
echo "⌨️ Mapeando Ctrl+Alt+T para abrir o Terminator diretamente..."

su - "$SUDO_USER" -c '
  SCHEMA="org.cinnamon.desktop.keybindings"
  KEY="custom-keybindings"
  KEY_NAME="custom0"
  KEY_PATH="/$KEY_NAME/"

  LIST=$(gsettings get $SCHEMA.$KEY custom-list)
  if [[ "$LIST" != *"$KEY_PATH"* ]]; then
    NEW_LIST=$(echo "$LIST" | sed "s/]$/, '"'"'$KEY_PATH'"'"']/")
    gsettings set $SCHEMA.$KEY custom-list "$NEW_LIST"
  fi

  gsettings set $SCHEMA.$KEY:$KEY_PATH name "Abrir Terminator"
  gsettings set $SCHEMA.$KEY:$KEY_PATH command "terminator"
  gsettings set $SCHEMA.$KEY:$KEY_PATH binding "['<Control><Alt>t']"

  echo "  ✅ Ctrl+Alt+T agora abre o Terminator diretamente."
'

echo "🧹 Limpando cache do apt..."
apt clean

echo "✅ Ambiente básico configurado com sucesso!"

echo ""
echo "⚠️ O atalho Ctrl + Alt + T agora abre o Terminator. Reinicie a sessão para garantir a aplicação."
echo "⚠️ Para ativar o ZSH com Agnoster, feche o terminal atual e abra um novo."
