export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  history
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

export HISTFILE=/commandhistory/.zsh_history

eval "$(starship init zsh)"
