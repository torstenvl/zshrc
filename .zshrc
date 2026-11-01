export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export PYTHON_HISTORY=/dev/null
export LESSHISTFILE=-
export SQLITE_HISTORY=/dev/null


# USE A GOOD EDITOR
if [ -f "/usr/local/bin/emacs" ]; then
   export EDITOR="/usr/local/bin/emacs"
elif [ -f "/usr/bin/emacs" ]; then
   export EDITOR="/usr/bin/emacs"
elif [ -f "/usr/bin/mg" ]; then
   export EDITOR="/usr/bin/mg"
elif [ -f "/usr/bin/nano" ]; then
   export EDITOR="/usr/bin/nano"
elif [ -f "/usr/local/bin/nano" ]; then
   export EDITOR="/usr/local/bin/nano"
fi


# SET UP PROMPTS AND AUTOCOMPLETION
if [[ "${ZSH_NAME}" == "zsh" ]]; then
    SHELL_SESSIONS_DISABLE=1
    PS1='[%B%D{%H:%M:%S} %F{red}%n@%m%f %F{green}%~%f%b] $ '
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
    autoload -Uz url-quote-magic
    zle -N self-insert url-quote-magic
    unsetopt BEEP
    setopt sharehistory
    setopt nobanghist
elif [[ "$(BASENAME ${BASH})" == "bash" ]] && [[ "${HISTFILE}" =~ "bash" ]]; then
    PS1="[\[\033[1m\]\t\[\033[m\] \[\033[1;31m\]\u@\h\[\033[m\] (bash) \[\e[32;1m\]\w\[\033[m\]] \$ "
    export BASH_SILENCE_DEPRECATION_WARNING=1
    export HISTFILE="${HOME}/.config/shell/.bash_history"
    set show-all-if-ambiguous on
    [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
else
    PS1="[\A \u@\h \w] \$ "
fi


## COMMON UNIX TUI ALIASES
alias cp='cp -iv'
alias mv='mv -iv'
alias less='less -FSRXc'
alias man='man -S "2:3:1:4:5:6:7:8:9"'
alias mkdir='mkdir -pv'
alias ls='ls -FGhp'
alias ll='ls -FGlhp'
alias la='ls -FGlAhp'
alias f='find . -name'
if ! command -v wget >/dev/null; then
    wget() {
        for url in "${@}"; do
            if ! curl -fLJOs "${url}"; then
                target="index.html"
                while true; do
                    if [ ! -e "${target}" ]; then
                        touch "${target}"
                        echo -n "Remote file name not detected: saving \"$url\" as \"$target\"... "
                        if ! curl -fLJSs "${url}" -o "${target}"; then
                            rm -f "${target}"
                            echo "Failed!"
                        else
                            echo "success!"
                        fi
                        break
                    else
                        base="$(mktemp wget-download.XXXXXX)" || exit 1
                        target="${base}.html"
                        rm -f "${base}"
                    fi
                done
            fi
        done
    }
fi

## ARCHIVE FUNCTIONS
extract () { case "${1}" in *.tar.bz2) tar xjf $1;; *.tbz2) tar xjf $1;; *.tar.gz) tar xzf $1;; *.tgz) tar xzf $1;; *.bz2) bunzip2 $1;; *.gz) gunzip $1;; *.tar) tar xf $1;; *.zip) unzip $1;; *) echo "Unrecognized archive." ;; esac }
mkzip   () { zip -r "$1".zip "$1" ; }
mktbz   () { tar cjvf "$1".tbz2 "$1" ; }
mktgz   () { tar czvf "$1".tgz "$1" ; }
gittimetravelcommit () { 
    if [ -e $1 ]; then
        GIT_COMMITTER_DATE="$(date -r "${1}" +'%Y-%m-%d %H:%M:%S %z')" GIT_AUTHOR_DATE="$(date -r "${1}" +'%Y-%m-%d %H:%M:%S %z')" git commit ${@:2} 
    else
        echo "File '${1}' does not exist"
        echo "Usage: gittimetravelcommit <file to take timestamp from> [options for git commit]"
    fi
}


## TOGGLE WHETHER PROMPT SHOWS USER NAME
anon() {
    while [ 1=1 ]; do
    [[ $PS1 =~ user.*green ]] && PS1='[%B%D{%H:%M:%S} %F{red}%n@%m%f %F{green}%~%f%b] $ ' && break;
    [[ $PS1 =~ \%n\@.*green ]] && PS1='[%B%D{%H:%M:%S} %F{red}user@%m%f %F{green}%~%f%b] $ ' && break;
    [[ $PS1 =~ user\@\\h ]] && PS1='[\[\033[1m\]\t\[\033[m\] \[\033[1;31m\]\u@\h\[\033[m\] (bash) \[\e[32;1m\]\w\[\033[m\]] $ ' && break;
    [[ $PS1 =~ \\u\@\\h ]] &&  PS1='[\[\033[1m\]\t\[\033[m\] \[\033[1;31m\]user@\h\[\033[m\] (bash) \[\e[32;1m\]\W\[\033[m\]] $ ' && break;
    done
}


## MAC ENV VARS & CONVENIENCE ALIASES
if [[ $OSTYPE == 'darwin'* ]]; then
    export PATH="/opt/local/bin:/opt/local/sbin:${HOME}/.bin:${PATH}"

    [ -f /usr/local/bin/betterls ] && alias ls='/usr/local/bin/betterls -FGhp --group-directories-first --group-dots-extra-first'
    [ -f /usr/local/bin/betterls ] && alias ll='/usr/local/bin/betterls -FGlhp --group-directories-first --group-dots-extra-first'
    [ -f /usr/local/bin/betterls ] && alias la='/usr/local/bin/betterls -FGlAhp --group-directories-first --group-dots-extra-first'
    alias flushdns='dscacheutil -flushcache'
    alias flushlocatedb='updatedb'
    alias flushlaunchsvcs="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
    alias flushdsstore='find ~ -name ".DS_Store" -delete'
    mkiso() { hdiutil makehybrid -iso -joliet -o "${1}.iso" "${1}" ; }
    procsample() { sample $1 30 1 -wait -mayDie -fullPaths -file /tmp/procsample__temp.txt && open /tmp/procsample__temp.txt ; }
    showlibs() { DYLD_PRINT_LIBRARIES=YES $@ ; }
    pem2p12() { openssl pkcs12 -export -inkey $1 -in $2 -name code-signing -out $3 ; }
fi


## FREEBSD ENV VARS & CONVENIENCE ALIASES
if [[ $OSTYPE == 'freebsd'* ]]; then
    export PATH="/usr/local/sbin:${HOME}/.bin:${PATH}"

    udc () {
    	GOOD=0 
    	MINE=$(freebsd-version) 
    	printf "LATEST UPDATES:\n"
    	fetch -qo - https://www.freebsd.org/releases/ | grep 'Release [0-9]' | sed 's/^.*Release \([0-9\.]*\).*\(([A-Za-z0-9 ,]*)\).*$/\1/g' | while read i
    	do
    		PLVL=$(fetch -qo - https://raw.githubusercontent.com/freebsd/freebsd-src/releng/$(echo $i)/sys/conf/newvers.sh | grep -E "BRANCH" | grep "=" | head -1 | cut -d"=" -f2 | sed 's/RELEASE-//g' | xargs) 
    		THISVER=$(printf "%-4s-RELEASE-%s\n" "${i}" "${PLVL}") 
    		printf "    ${THISVER}"
    		[ "${THISVER}" = "${MINE}" ] && GOOD=1  && printf " (your system)\n" || printf "\n"
    	done
    	[ "${GOOD}" = "0" ] && printf "\nPlease update your system from ${FVER} via freebsd-update.\n\n" || printf "\nYour system is up to date.\n\n"
    }
fi

