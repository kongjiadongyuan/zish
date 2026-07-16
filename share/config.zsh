# Managed by install-fishlike-zsh.sh; edits may be replaced.
# Runtime config. Paths come from env.zsh (written by the installer).
#
# Design: stay small. Do not paper over a broken shell environment here.
# Fix login issues in ~/.zprofile (use: emulate sh -c 'source ~/.profile').

emulate zsh

# ---- options ----------------------------------------------------------------
export HISTFILE="${HISTFILE:-${ZDOTDIR:-$HOME}/.zsh_history}"
export HISTSIZE="${HISTSIZE:-100000}"
export SAVEHIST="${SAVEHIST:-100000}"

setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS NO_BEEP PROMPT_SUBST
setopt EXTENDED_GLOB          # required by ez-compinit and many plugins
setopt FUNCTION_ARGZERO       # plugins that resolve paths from $0

autoload -Uz colors add-zsh-hook
colors

# ---- PATH / colors ----------------------------------------------------------
if [[ -d ${FISHLIKE_LOCAL_BIN:-} ]]; then
  case ":$PATH:" in
    *":$FISHLIKE_LOCAL_BIN:"*) ;;
    *) PATH="$FISHLIKE_LOCAL_BIN:$PATH" ;;
  esac
fi

if command -v dircolors >/dev/null 2>&1; then
  if [[ -r $HOME/.dircolors ]]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi
export CLICOLOR="${CLICOLOR:-1}"
export LSCOLORS="${LSCOLORS:-exfxcxdxbxegedabagacad}"

# ---- prompt -----------------------------------------------------------------
_fishlike_prompt() {
  local last=$? branch short gitseg status
  # abbreviated path like fish
  short="${PWD/#$HOME/~}"
  if [[ $short != / && $short == */* ]]; then
    local -a parts=("${(@s:/:)short}")
    local -i i
    for (( i = 1; i < ${#parts}; i++ )); do
      [[ -n $parts[i] ]] || continue
      if [[ $parts[i] == .* ]]; then
        parts[i]=${parts[i][1,2]}
      else
        parts[i]=${parts[i][1,1]}
      fi
    done
    short=${(j:/:)parts}
  fi
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null \
      || git rev-parse --short HEAD 2>/dev/null) || branch=
    [[ -n $branch ]] && gitseg=" %F{magenta}(${branch})%f"
  fi
  (( last )) && status=" %B%F{red}[${last}]%f%b"
  PROMPT="%B%F{green}%n%b%f@%m %F{green}${short}%f${gitseg}${status}%(!.#.>) "
}
precmd_functions=(_fishlike_prompt ${precmd_functions:#_fishlike_prompt})

# terminal title
_fishlike_title() { [[ -t 1 && $TERM != dumb ]] && print -Pn '\e]0;%n@%m: %~\a' }
add-zsh-hook precmd _fishlike_title

# ---- plugins (read-only; built at install time) ------------------------------
# The installer writes FISHLIKE_PLUGIN_BUNDLE via Antidote once. Startup must
# not clone, rebuild, or quarantine — re-run the installer to repair.
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group '<' '>'

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=green,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'

if [[ -r ${FISHLIKE_PLUGIN_BUNDLE:-} ]]; then
  source "${FISHLIKE_PLUGIN_BUNDLE}"
  # ez-compinit defers real compinit to precmd; fzf-tab needs it now.
  if (( $+functions[run-compinit] )); then
    run-compinit
  else
    autoload -Uz compinit && compinit -C
  fi
  (( $+functions[enable-fzf-tab] )) && enable-fzf-tab
else
  print -u2 'fishlike-zsh: missing plugin bundle; run the installer again'
  autoload -Uz compinit && compinit -C
fi

# ---- directory history (prevd / nextd / cdh) ---------------------------------
typeset -ga _fishlike_dirs=("$PWD")
typeset -gi _fishlike_dirs_i=1
typeset -gi _fishlike_dirs_nav=0

_fishlike_dirs_push() {
  (( _fishlike_dirs_nav )) && return 0
  if (( _fishlike_dirs_i < ${#_fishlike_dirs} )); then
    _fishlike_dirs=("${_fishlike_dirs[@]:0:_fishlike_dirs_i}")
  fi
  if (( ${#_fishlike_dirs} == 0 )) || [[ ${_fishlike_dirs[-1]} != $PWD ]]; then
    _fishlike_dirs+=("$PWD")
    (( ${#_fishlike_dirs} > 50 )) && _fishlike_dirs=("${_fishlike_dirs[@]: -50}")
  fi
  _fishlike_dirs_i=${#_fishlike_dirs}
}
add-zsh-hook chpwd _fishlike_dirs_push

prevd() {
  (( _fishlike_dirs_i <= 1 )) && { print -u2 'prevd: beginning'; return 1 }
  _fishlike_dirs_nav=1
  _fishlike_dirs_i=$((_fishlike_dirs_i - 1))
  cd -- "$_fishlike_dirs[_fishlike_dirs_i]" || { _fishlike_dirs_nav=0; return 1 }
  _fishlike_dirs_nav=0
}
nextd() {
  (( _fishlike_dirs_i >= ${#_fishlike_dirs} )) && { print -u2 'nextd: end'; return 1 }
  _fishlike_dirs_nav=1
  _fishlike_dirs_i=$((_fishlike_dirs_i + 1))
  cd -- "$_fishlike_dirs[_fishlike_dirs_i]" || { _fishlike_dirs_nav=0; return 1 }
  _fishlike_dirs_nav=0
}
cdh() {
  (( ${#_fishlike_dirs} )) || { print -u2 'cdh: empty'; return 1 }
  local dest
  if (( $+commands[fzf] )); then
    dest=$(printf '%s\n' "${_fishlike_dirs[@]}" | fzf --height=40% --reverse --tac --prompt='cdh> ') || return 1
  else
    local i=1 d n
    for d in "${_fishlike_dirs[@]}"; do print -r -- "$i  $d"; (( i++ )); done
    print -n 'cdh number: '; read -r n
    [[ $n == <-> && n -ge 1 && n -le ${#_fishlike_dirs} ]] || return 1
    dest=$_fishlike_dirs[n]
  fi
  [[ -n $dest ]] && cd -- "$dest"
}

# ---- key bindings -----------------------------------------------------------
_fishlike_alt_left() {
  if [[ -z $BUFFER && -z $PREBUFFER ]]; then prevd 2>/dev/null; zle reset-prompt
  else zle backward-word; fi
}
_fishlike_alt_right() {
  if [[ -z $BUFFER && -z $PREBUFFER ]]; then nextd 2>/dev/null; zle reset-prompt
  else zle forward-word; fi
}
zle -N _fishlike_alt_left
zle -N _fishlike_alt_right

if (( $+commands[fzf] )); then
  _fishlike_history() {
    local selected
    selected=$(fc -rln 1 2>/dev/null | awk 'NF && !seen[$0]++' \
      | fzf --height=40% --reverse --tiebreak=index --query="$LBUFFER" --prompt='hist> ' --scheme=history) \
      && LBUFFER=$selected
    zle reset-prompt
  }
  zle -N _fishlike_history
fi

(( $+functions[_zsh_autosuggest_bind_widgets] )) && _zsh_autosuggest_bind_widgets

bindkey -e
if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
else
  bindkey '^[[A' up-line-or-history
  bindkey '^[[B' down-line-or-history
  bindkey '^[OA' up-line-or-history
  bindkey '^[OB' down-line-or-history
fi
bindkey '^[[C' forward-char
bindkey '^[OC' forward-char
if (( $+widgets[autosuggest-accept] )); then
  bindkey '^[[F' autosuggest-accept
  bindkey '^[OF' autosuggest-accept
  bindkey '^[[4~' autosuggest-accept
fi
bindkey '^[b' _fishlike_alt_left
bindkey '^[f' _fishlike_alt_right
bindkey '^[[1;3D' _fishlike_alt_left
bindkey '^[[1;3C' _fishlike_alt_right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
(( $+widgets[_fishlike_history] )) && bindkey '^R' _fishlike_history

# ---- aliases ----------------------------------------------------------------
if command ls --color=auto / >/dev/null 2>&1; then
  alias ls='ls --color=auto' ll='ls -lah --color=auto' la='ls -A --color=auto' l='ls -CF --color=auto'
elif command ls -G / >/dev/null 2>&1; then
  alias ls='ls -G' ll='ls -lahG' la='ls -AG' l='ls -CFG'
else
  alias ll='ls -lah' la='ls -A' l='ls -CF'
fi

# ---- local overrides --------------------------------------------------------
[[ -r ${FISHLIKE_LOCAL_RC:-} ]] && source "$FISHLIKE_LOCAL_RC"
