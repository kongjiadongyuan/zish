# Managed by zish; edits may be replaced.
# Runtime config. Installed to ~/.config/zish/config.zsh.
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
if [[ -d ${ZISH_BIN:-} ]]; then
  case ":$PATH:" in
    *":$ZISH_BIN:"*) ;;
    *) PATH="$ZISH_BIN:$PATH" ;;
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
_zish_prompt() {
  # Capture exit status first. Do not name locals "status" — in zsh that is a
  # read-only special parameter ($?); assigning it errors and leaves $status=1
  # glued onto the path in PROMPT (looks like "~1").
  local last=$? branch short gitseg errseg
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
  (( last )) && errseg=" %B%F{red}[${last}]%f%b"
  PROMPT="%B%F{green}%n%b%f@%m %F{green}${short}%f${gitseg}${errseg}%(!.#.>) "
}
precmd_functions=(_zish_prompt ${precmd_functions:#_zish_prompt})

# terminal title
_zish_title() { [[ -t 1 && $TERM != dumb ]] && print -Pn '\e]0;%n@%m: %~\a' }
add-zsh-hook precmd _zish_title

# ---- plugins (read-only; built at install time) ------------------------------
# The installer writes ZISH_PLUGIN_BUNDLE via Antidote once. Startup must
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

if [[ -r ${ZISH_PLUGIN_BUNDLE:-} ]]; then
  source "${ZISH_PLUGIN_BUNDLE}"
  # ez-compinit defers real compinit to precmd; fzf-tab needs it now.
  if (( $+functions[run-compinit] )); then
    run-compinit
  else
    autoload -Uz compinit && compinit -C
  fi
  (( $+functions[enable-fzf-tab] )) && enable-fzf-tab
else
  print -u2 'zish: missing plugin bundle; run the installer again'
  autoload -Uz compinit && compinit -C
fi

# ---- directory history (prevd / nextd / cdh) ---------------------------------
typeset -ga _zish_dirs=("$PWD")
typeset -gi _zish_dirs_i=1
typeset -gi _zish_dirs_nav=0

_zish_dirs_push() {
  (( _zish_dirs_nav )) && return 0
  if (( _zish_dirs_i < ${#_zish_dirs} )); then
    _zish_dirs=("${_zish_dirs[@]:0:_zish_dirs_i}")
  fi
  if (( ${#_zish_dirs} == 0 )) || [[ ${_zish_dirs[-1]} != $PWD ]]; then
    _zish_dirs+=("$PWD")
    (( ${#_zish_dirs} > 50 )) && _zish_dirs=("${_zish_dirs[@]: -50}")
  fi
  _zish_dirs_i=${#_zish_dirs}
}
add-zsh-hook chpwd _zish_dirs_push

prevd() {
  (( _zish_dirs_i <= 1 )) && { print -u2 'prevd: beginning'; return 1 }
  _zish_dirs_nav=1
  _zish_dirs_i=$((_zish_dirs_i - 1))
  cd -- "$_zish_dirs[_zish_dirs_i]" || { _zish_dirs_nav=0; return 1 }
  _zish_dirs_nav=0
}
nextd() {
  (( _zish_dirs_i >= ${#_zish_dirs} )) && { print -u2 'nextd: end'; return 1 }
  _zish_dirs_nav=1
  _zish_dirs_i=$((_zish_dirs_i + 1))
  cd -- "$_zish_dirs[_zish_dirs_i]" || { _zish_dirs_nav=0; return 1 }
  _zish_dirs_nav=0
}
cdh() {
  (( ${#_zish_dirs} )) || { print -u2 'cdh: empty'; return 1 }
  local dest
  if (( $+commands[fzf] )); then
    dest=$(printf '%s\n' "${_zish_dirs[@]}" | fzf --height=40% --reverse --tac --prompt='cdh> ') || return 1
  else
    local i=1 d n
    for d in "${_zish_dirs[@]}"; do print -r -- "$i  $d"; (( i++ )); done
    print -n 'cdh number: '; read -r n
    [[ $n == <-> && n -ge 1 && n -le ${#_zish_dirs} ]] || return 1
    dest=$_zish_dirs[n]
  fi
  [[ -n $dest ]] && cd -- "$dest"
}

# ---- key bindings -----------------------------------------------------------
_zish_alt_left() {
  if [[ -z $BUFFER && -z $PREBUFFER ]]; then prevd 2>/dev/null; zle reset-prompt
  else zle backward-word; fi
}
_zish_alt_right() {
  if [[ -z $BUFFER && -z $PREBUFFER ]]; then nextd 2>/dev/null; zle reset-prompt
  else zle forward-word; fi
}
zle -N _zish_alt_left
zle -N _zish_alt_right

if (( $+commands[fzf] )); then
  _zish_history() {
    local selected
    selected=$(fc -rln 1 2>/dev/null | awk 'NF && !seen[$0]++' \
      | fzf --height=40% --reverse --tiebreak=index --query="$LBUFFER" --prompt='hist> ' --scheme=history) \
      && LBUFFER=$selected
    zle reset-prompt
  }
  zle -N _zish_history
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
bindkey '^[b' _zish_alt_left
bindkey '^[f' _zish_alt_right
bindkey '^[[1;3D' _zish_alt_left
bindkey '^[[1;3C' _zish_alt_right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
(( $+widgets[_zish_history] )) && bindkey '^R' _zish_history

# ---- aliases ----------------------------------------------------------------
if command ls --color=auto / >/dev/null 2>&1; then
  alias ls='ls --color=auto' ll='ls -lah --color=auto' la='ls -A --color=auto' l='ls -CF --color=auto'
elif command ls -G / >/dev/null 2>&1; then
  alias ls='ls -G' ll='ls -lahG' la='ls -AG' l='ls -CFG'
else
  alias ll='ls -lah' la='ls -A' l='ls -CF'
fi

# ---- update notice ----------------------------------------------------------
# Cached; a background check runs at most once a day. Never blocks startup.
if [[ -o interactive && -t 1 ]] && (( $+commands[zish] )); then
  zish notice
fi
