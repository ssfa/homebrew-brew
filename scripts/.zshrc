# version:20240417

[ `uname` = 'Linux' ] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
[ `uname` = 'Darwin' ] && [[ -f /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)
[ `uname` = 'Darwin' ] && [[ -f /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# zinit Plugin Manager
source $(brew --prefix)/opt/zinit/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

## zsh plugins
setopt promptsubst

zinit wait lucid for \
  OMZL::clipboard.zsh  OMZL::completion.zsh  OMZL::functions.zsh \
  OMZL::git.zsh        OMZL::history.zsh     OMZL::key-bindings.zsh \
  OMZL::misc.zsh       OMZL::theme-and-appearance.zsh \
  agkozak/zsh-z \
  OMZP::fzf/fzf.plugin.zsh \
  OMZP::colored-man-pages/colored-man-pages.plugin.zsh
# OMZP::kubectl/kubectl.plugin.zsh

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

export SCM_BREEZE_DISABLE_ASSETS_MANAGEMENT="true"
zinit light scmbreeze/scm_breeze

# Env
export EDITOR=vim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Utilities
alias cat='bat'
alias l='ll'
export PATH="$HOME/.cargo/bin:$PATH"

eval "$(starship init zsh)"
eval "$(mise activate zsh)"
eval "$(mise activate zsh --shims)"

# async evals
SNIPPET_FILE=$HOME/.zinit.evals.20240417.zsh
if [ ! -f $SNIPPET_FILE ]; then
cat <<-EOF > $SNIPPET_FILE
eval "\$(direnv hook zsh)"
eval "\$(features init -)"
EOF
fi
zinit wait lucid for is-snippet $SNIPPET_FILE
#export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local
