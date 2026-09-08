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
setopt EXTENDED_GLOB
setopt FUNCTION_ARGZERO

autoload -Uz add-zsh-hook

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

# ---- theme (zish theme <name>; selection in $ZISH_DIR/theme) ----------------
typeset -g ZISH_THEME=default
typeset -g ZISH_C_USER=00afd7 ZISH_C_HOST=d7af00 ZISH_C_PATH=5fd75f
typeset -g ZISH_C_GIT=d787d7 ZISH_C_ERROR=ff5f5f ZISH_C_SUGGEST=808080

_zish_load_theme() {
  emulate -L zsh
  local name line
  local -a f
  if [[ -r ${ZISH_DIR:-}/theme ]]; then
    name=${$(<${ZISH_DIR}/theme)//[[:space:]]/}
  fi
  [[ -n $name ]] || name=default
  if [[ -r ${ZISH_DIR:-}/themes.txt ]]; then
    while IFS= read -r line; do
      [[ -z $line || $line == \#* ]] && continue
      f=(${=line})
      (( $#f >= 7 )) || continue
      if [[ $f[1] == $name ]]; then
        ZISH_C_USER=$f[2] ZISH_C_HOST=$f[3] ZISH_C_PATH=$f[4]
        ZISH_C_GIT=$f[5] ZISH_C_ERROR=$f[6] ZISH_C_SUGGEST=$f[7]
        ZISH_THEME=$name
        break
      fi
    done < ${ZISH_DIR}/themes.txt
  fi
}
_zish_load_theme

# ---- prompt -----------------------------------------------------------------
# Read .git/HEAD instead of spawning git. Walk parents with [[ -e ]], not git.
_zish_git_branch() {
  emulate -L zsh
  local d=$PWD gitdir head raw
  while true; do
    if [[ -d $d/.git ]]; then
      gitdir=$d/.git
      break
    elif [[ -f $d/.git ]]; then
      IFS= read -r raw < $d/.git || return 1
      gitdir=${raw#gitdir:}
      gitdir=${gitdir##[[:space:]]#}
      [[ $gitdir == /* ]] || gitdir=$d/$gitdir
      break
    fi
    [[ $d == / ]] && return 1
    d=${d:h}
  done
  [[ -r $gitdir/HEAD ]] || return 1
  IFS= read -r head < $gitdir/HEAD || return 1
  if [[ $head == ref:\ refs/heads/* ]]; then
    REPLY=${head#ref: refs/heads/}
  else
    REPLY=${head[1,7]}
  fi
}

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
  if _zish_git_branch; then
    gitseg=" %F{#$ZISH_C_GIT}(${REPLY})%f"
  fi
  (( last )) && errseg=" %B%F{#$ZISH_C_ERROR}[${last}]%f%b"
  PROMPT="%B%F{#$ZISH_C_USER}%n%b%f@%F{#$ZISH_C_HOST}%m%f %F{#$ZISH_C_PATH}${short}%f${gitseg}${errseg}%(!.#.>) "
}
precmd_functions=(_zish_prompt ${precmd_functions:#_zish_prompt})

_zish_title() { [[ -t 1 && $TERM != dumb ]] && print -Pn '\e]0;%n@%m: %~\a' }
add-zsh-hook precmd _zish_title

# ---- plugins ----------------------------------------------------------------
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group '<' '>'

# history only: the completion strategy runs the full completer on every keystroke.
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#$ZISH_C_SUGGEST"
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=green,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'

# One completion init. If something else already ran compinit, do not run it
# again — a second uncached pass is the bulk of startup. fzf-tab self-enables.
typeset -g ZSH_COMPDUMP="${ZSH_COMPDUMP:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump}"
if (( ! $+_comps )); then
  [[ -d $ZSH_COMPDUMP:h ]] || mkdir -p $ZSH_COMPDUMP:h
  autoload -Uz compinit
  if [[ -r $ZSH_COMPDUMP ]]; then
    compinit -C -d $ZSH_COMPDUMP
  else
    compinit -i -d $ZSH_COMPDUMP
  fi
fi

if [[ -r ${ZISH_PLUGIN_BUNDLE:-} ]]; then
  source "${ZISH_PLUGIN_BUNDLE}"
else
  print -u2 'zish: missing plugin bundle; run the installer again'
fi

# zsh-abbr: 60KB + filesystem job queue. Load only when used.
_zish_abbr_plugin=$ZISH_DIR/plugins/github.com/olets/zsh-abbr/zsh-abbr.plugin.zsh
_zish_load_abbr() {
  [[ -r $_zish_abbr_plugin ]] || return 1
  fpath+=( ${_zish_abbr_plugin:h} ${_zish_abbr_plugin:h}/completions )
  # zsh-abbr's trailing unfunction -m returns 1; ignore it.
  source $_zish_abbr_plugin || true
  (( $+functions[abbr-expand] || $+widgets[abbr-expand] ))
}
_zish_abbr_lazy() {
  unalias abbr 2>/dev/null
  unfunction _zish_abbr_lazy 2>/dev/null
  _zish_load_abbr || { print -u2 'zish: zsh-abbr missing'; return 1 }
  abbr "$@"
}
alias abbr=_zish_abbr_lazy
if [[ -s ${XDG_CONFIG_HOME:-$HOME/.config}/zsh-abbr/user-abbreviations ||
      -s ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/abbreviations ]]; then
  unalias abbr 2>/dev/null
  unfunction _zish_abbr_lazy 2>/dev/null
  _zish_load_abbr
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
case $OSTYPE in
  darwin*|freebsd*)
    alias ls='ls -G' ll='ls -lahG' la='ls -AG' l='ls -CFG'
    ;;
  *)
    if command ls --color=auto / >/dev/null 2>&1; then
      alias ls='ls --color=auto' ll='ls -lah --color=auto' la='ls -A --color=auto' l='ls -CF --color=auto'
    else
      alias ll='ls -lah' la='ls -A' l='ls -CF'
    fi
    ;;
esac

# ---- update notice (zsh; do not spawn bash on every startup) ----------------
_zish_notice() {
  emulate -L zsh
  setopt extendedglob
  local -A st ck
  local line now age
  [[ -r $ZISH_DIR/state ]] || return 0
  for line in "${(@f)$(<$ZISH_DIR/state)}"; do
    [[ $line == [a-z_]##=* ]] && st[${line%%=*}]=${line#*=}
  done
  [[ -n $st[version] ]] || return 0
  if [[ -r $ZISH_DIR/update-check ]]; then
    for line in "${(@f)$(<$ZISH_DIR/update-check)}"; do
      [[ $line == [a-z_]##=* ]] && ck[${line%%=*}]=${line#*=}
    done
  fi
  if [[ -n $ck[remote] && $ck[remote] != $st[version] ]]; then
    if [[ -t 2 ]]; then
      print -u2 -- "\033[1;33mzish update available:\033[0m ${st[version]} → ${ck[remote]}   run \033[1mzish update\033[0m"
    else
      print -u2 -- "zish update available: ${st[version]} → ${ck[remote]}   run zish update"
    fi
  fi
  zmodload -F zsh/datetime p:EPOCHSECONDS 2>/dev/null
  now=${EPOCHSECONDS:-0}
  age=$(( now - ${ck[checked_at]:-0} ))
  if [[ -z $ck[checked_at] ]] || (( age >= 86400 || age < 0 )); then
    if (( $+commands[zish] )); then
      (command zish check --quiet >/dev/null 2>&1 &)
    fi
  fi
}
if [[ -o interactive && -t 1 ]]; then
  _zish_notice
fi

# Byte-compile plugins when .zwc is missing or stale. Fork only if work remains.
() {
  emulate -L zsh
  local -a needs
  local f
  for f in \
    $ZISH_DIR/config.zsh \
    $ZISH_DIR/plugins.zsh \
    $ZISH_DIR/plugins/github.com/Aloxaf/fzf-tab/fzf-tab.zsh \
    $ZISH_DIR/plugins/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh \
    $ZISH_DIR/plugins/github.com/zsh-users/zsh-history-substring-search/zsh-history-substring-search.zsh \
    $ZISH_DIR/plugins/github.com/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    $ZISH_DIR/plugins/github.com/zsh-users/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh
  do
    [[ -r $f && ( ! -s $f.zwc || $f -nt $f.zwc ) ]] && needs+=$f
  done
  (( $#needs )) || return
  {
    for f in $needs; do zcompile -R -- $f 2>/dev/null; done
  } &!
}
