# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != "linux"
        alias ls 'eza --icons=auto'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end

    alias v vim
    alias vi vim
    alias nv nvim
    alias netstat 'ss -tunap | grep ESTAB'
end

set -gx SHELL (which fish)

# bun
set BUN_INSTALL $HOME/.bun
set PATH $PATH $BUN_INSTALL/bin

# set PATH $PATH $HOME/.local/share/nvim/mason/bin
set PATH $PATH $HOME/develop/flutter/bin

set EDITOR vim
set SYSTEM_LESS FRSXM # make journalctl less work as normal

# Added by Antigravity CLI installer
set -gx PATH "$HOME/.local/bin" $PATH

# Android SDK Paths
set ANDROID_HOME $HOME/Android/Sdk
set PATH $PATH:$ANDROID_HOME/emulator
set PATH $PATH:$ANDROID_HOME/platform-tools
# set PATH $PATH:$ANDROID_HOME/cmdline-tools/latest/bin
# set PATH $PATH:$ANDROID_HOME/tools/bin

# set http_proxy "http://172.16.48.85:8080"
# set https_proxy "http://172.16.48.85:8080"
#
# set HTTP_PROXY "http://172.16.48.85:8080"
# set HTTPS_PROXY "http://172.16.48.85:8080"

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
