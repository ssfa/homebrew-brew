# version:20220201

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
  OMZP::colored-man-pages/colored-man-pages.plugin.zsh \
  OMZP::kubectl/kubectl.plugin.zsh

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

zinit light scmbreeze/scm_breeze

# Env
export EDITOR=vim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Utilities
alias cat='bat'
export PATH="$HOME/.cargo/bin:$PATH"
eval "$(starship init zsh)"

# async evals
SNIPPET_FILE=$HOME/.zinit.evals.20220201.zsh
if [ ! -f $SNIPPET_FILE ]; then
cat <<-EOF > $SNIPPET_FILE
eval "\$(direnv hook zsh)"
eval "\$(nodenv init -)"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"
eval "\$(goenv init -)"
eval "\$(rbenv init -)"
eval "\$(features init -)"
EOF
fi
zinit wait lucid for is-snippet $SNIPPET_FILE

export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

