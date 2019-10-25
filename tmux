# START tmux bash_completion  -*- Hey emacs! mode:shell-script; -*-
#
# ©2019 Boruch Baum <boruch_baum@gmx.com>
# License: GPL3+
#
# Developed for tmux version 2.8 (tmux -V). Changes to reflect future
# versions should check for the version number, so that this script
# continues to work for all supported versions.
#
# Ref:         http://www.debian-administration.org/articles/317
# Inspiration: https://github.com/srsudar/tmux-completion
#
# Instructions: Choose any one of the following:
# 1] from the command line, run: source path/to/this/file
# 2] source this file from ~/.bashrc, ~/.bash_profile, or ~/.bash_completion
# 3] add the file to /etc/bash_completion or /etc/bash_completion.d/

_tmux()
{
  local completion_list \
        commands \
        index \
        server_options \
        session_options \
        tmux_command \
        window_options \
        word_current \
        word_prior
  COMPREPLY=()
  word_current="${COMP_WORDS[COMP_CWORD]}"
  word_prior="${COMP_WORDS[COMP_CWORD-1]}"
  tmux_command="${COMP_WORDS[1]}"
  commands=" \
    attach-session        bind-key            break-pane             capture-pane         \
    choose-client         choose-session      choose-window          clear-history        \
    clock-mode            command-prompt      confirm-before         copy-buffer          \
    copy-mode             delete-buffer       detach-client          display-message      \
    display-panes         down-pane           find-window            has-session          \
    if-shell              join-pane           kill-pane              kill-server          \
    kill-session          kill-window         last-window            link-window          \
    list-buffers          list-clients        list-commands          list-keys            \
    list-panes            list-sessions       list-windows           load-buffer          \
    lock-client           lock-server         lock-session           move-window          \
    new-session           new-window          next-layout            next-window          \
    paste-buffer          pipe-pane           previous-layout        previous-window      \
    refresh-client        rename-session      rename-window          resize-pane          \
    respawn-window        rotate-window       run-shell              save-buffer          \
    select-layout         select-pane         select-prompt          select-window        \
    send-keys             send-prefix         server-info            set-buffer           \
    set-environment       set-option          set-window-option      show-buffer          \
    show-environment      show-messages       show-options           show-window-options  \
    source-file           split-window        start-server           suspend-client       \
    swap-pane             swap-window         switch-client          unbind-key           \
    unlink-window         up-pane"
  server_options=" \
    buffer-limit   command-alias    default-terminal    escape-time \
    exit-empty     exit-unattached  focus-events        history-file   \
    message-limit  set-clipboard    terminal-overrides"
  session_options=" \
    activity-action              assume-paste-time           base-index         \
    bell-action                  default-command             default-shell      \
    detach-on-destroy            display-panes-active-colou  display-panes-colour  \
    display-panes-time           history-limit               key-table          \
    lock-after-time              lock-command                message-command-style \
    message-style                mouse                       prefix             \
    prefix2                      renumber-windows            repeat-time        \
    set-titles                   set-titles-string           silence-action     \
    status                       status-interval             status-justify     \
    status-keys                  status-left                 status-left-length \
    status-left-style            status-position             status-right       \
    status-right-length          status-right-style          status-style       \
    update-environmentuser-keys  visual-activity             visual-bell        \
    visual-silence               word-separators"
  window_options=" \
    aggresive-resize              allow-rename                  automatic-rename      \
    automatic-rename-format       clock-mode-colour             clock-mode-style      \
    force-height                  force-width                   main-pane-height      \
    main-pane-width               mode-keys                     mode-style            \
    monitor-activity              monitor-bell                  monitor-silence       \
    other-pane-height             other-pane-width              pane-active-border-style \
    pane-base-index               pane-border-format            pane-border-status    \
    pane-border-style             remain-on-exit                synchronize-panes     \
    window-active-style           window-status-activity-style  window-status-bell-style \
    window-status-current-format  window-status-current-style   window-status-format  \
    window-status-last-style      window-status-separator       window-status-style   \
    window-style                  wrap-search                   xterm-keys"

  _get_tmux_buffer_list()
  {
    completion_list=$(tmux list-buffers -F "#{buffer_name}")
    COMPREPLY=($(compgen -W "${completion_list}" -- ${word_current}))
    }

  _get_tmux_client_list()
  {
    completion_list=$(tmux list-clients -F "#{client_name}")
    COMPREPLY=($(compgen -W "${completion_list}" -- ${word_current}))
    }

  _get_tmux_pane_list()
  {
    completion_list=$(tmux list-panes -F "#D")
    # Formats: #D=pane_id, #P=pane_index, #T=pane_title
    COMPREPLY=($(compgen -W "${completion_list}" -- ${word_current}))
    }

  _get_tmux_session_list()
  {
    completion_list=$(tmux list-sessions -F "#S")
    if [ "${completion_list[0]}" = "failed to connect to server" ]; then
      # we don't want to display any options, so clear the array.
      completion_list=$( )
    fi
    COMPREPLY=($(compgen -W "${completion_list}" -- ${word_current}))
    }

  _get_tmux_window_list()
  {
    completion_list=$(tmux list-windows -F "#W")
    # Formats: #I=window_index, #W=window_name, #{window_id}=window_id
    # WARNING: list-windows may be able to be used differently. I
    # think the second field, the window label, can be used in tmux
    # commands instead of the first field, which just a numeric
    # identifier. The issue would be names with embedded spaces.
    COMPREPLY=($(compgen -W "${completion_list}" -- ${word_current}))
    }

  _check_server_or_session_sub_options()
  {
    case "$word_prior" in
      activity-action | bell-action | silence-action)
        completion_list=" any none current other " ;;
    # default-shell | history-file) path
      set-clipboard)
        completion_list=" on off external " ;;
      detach-on-destroy | exit-empty       | exit-unattached |\
      mouse             | renumber-windows | set-titles      |\
      status)
        completion_list=" on off " ;;
      status-justify)
        completion_list=" left centre right" ;;
      status-keys)
        completion_list=" vi emacs " ;;
      status-position)
        completion_list=" top bottom " ;;
      visual-activity | visual-bell | visual-silence)
        completion_list=" on off both " ;;
    esac
    }

  _check_window_sub_options()
  {
    case "$word_prior" in
      aggresive-resize  | allow-rename | automatic-rename |\
      monitor-activity  | monitor-bell | remain-on-exit   |\
      synchronize-panes | wrap-search  | xterm-keys)
        completion_list=" on off " ;;
      pane-border-status)
        completion_list=" on off bottom " ;;
      clock-mode-style)
        completion_list=" 12 24 " ;;
      mode-keys)
        completion_list=" vi emacs " ;;
    esac
    }


  # _main()

  # nothing to do for these commands?
  # bind-key, list-keys, unbind-key

  # We start by catching unusually formatted tmux commands
  case $tmux_command in
  list-panes)
    if [ "$COMP_CWORD" -ge 2 ] && [[ "$word_prior" == "-t" ]]; then
      for ((index=$COMP_CWORD-1; index-1; index--)) ; do
        if [[ "${COMP_WORDS[index]}" == "-s" ]] ; then
          _get_tmux_session_list ; return 0
        fi
      done
      _get_tmux_window_list; return 0
    fi ;;
  set-option)
    if [ "$COMP_CWORD" -ge 2 ] && [[ "$word_prior" == "-t" ]]; then
      for ((index=$COMP_CWORD-1; index-1; index--)) ; do
        if [[ "${COMP_WORDS[index]}" == "-w" ]] ; then
          _get_tmux_window_list ; return 0
        fi
      done
      _get_tmux_session_list; return 0
    fi
    _check_server_or_session_sub_options
    [ -z "$completion_list" ] \
    && _check_window_sub_options
    [ -z "$completion_list" ] \
    && for ((index=$COMP_CWORD-1; index-1; index--)) ; do
         if [[ "${COMP_WORDS[index]}" == "-w" ]] ; then
           completion_list="$window_options"
         elif [[ "${COMP_WORDS[index]}" == "-s" ]] ; then
           completion_list="$server_options"
         fi
       done
    [ -z "$completion_list" ] && completion_list="$session_options"
    COMPREPLY=($(compgen -W "${completion_list}" -- ${word_current}))
    return 0 ;;

  set-window-option)
    if [ "$COMP_CWORD" -ge 2 ]; then
      if [[ "$word_prior" == "-t" ]]; then
        _get_tmux_window_list;  return 0
      else
        _check_window_sub_options
        [ -z "$completion_list" ] && completion_list="$window_options"
        COMPREPLY=($(compgen -W "${completion_list}" -- ${word_current}))
        return 0
      fi
    fi ;;

  show-options)
    if [ "$COMP_CWORD" -ge 2 ]; then
      if [[ "$word_prior" == "-t" ]]; then
        for ((index=$COMP_CWORD-1; index-1; index--)) ; do
          if [[ "${COMP_WORDS[index]}" == "-w" ]] ; then
            _get_tmux_window_list ; return 0
          fi
        done
        _get_tmux_session_list; return 0
      else
        for ((index=$COMP_CWORD-1; index-1; index--)) ; do
          if [[ "${COMP_WORDS[index]}" == "-w" ]] ; then
            completion_list="$window_options"
          elif [[ "${COMP_WORDS[index]}" == "-s" ]] ; then
            completion_list="$server_options"
          fi
        done
        [ -z "$completion_list" ] && completion_list="$session_options"
        COMPREPLY=($(compgen -W "${completion_list}" -- ${word_current}))
        return 0
      fi
    fi ;;

  show-window-options)
    if [ "$COMP_CWORD" -ge 2 ]; then
      if [[ "$word_prior" == "-t" ]]; then
        _get_tmux_window_list;  return 0
      else
        COMPREPLY=($(compgen -W "${window_options}" -- ${word_current}))
        return 0
      fi
    fi ;;

  set-hook)
    if [ "$COMP_CWORD" -ge 2 ]; then
      if [[ "$word_prior" == "-t" ]]; then
        _get_tmux_session_list;  return 0
      else
        echo "not yet done!"
        # list of hooks including all after-(command_*name) hooks
      fi
    fi ;;

  esac


  # After catching unusually formatted tmux commands above, we now
  # start processing the standard format commands
  if [ "$COMP_CWORD" -ge 2 ]; then
    case $word_prior in
    -b) case $tmux_command in
          capture-pane | delete-buffer | load-buffer |\
          paste-buffer | save-buffer   | set-buffer  |\
          show-buffer)
            _get_tmux_buffer_list;  return 0 ;;
        esac
        ;;
    -c) case $tmux_command in
          attach-session | new-session    | new-window |\
          respawn-pane   | respawn-window | split-window) # directory
            ;;
          display-message|switch-client)
            _get_tmux_client_list;  return 0 ;;
        esac
        ;;
    -s) case $tmux_command in
          break-pane | join-pane | move-pane | swap-pane)
            _get_tmux_pane_list
            return 0
            ;;
          detach-client)
            _get_tmux_session_list
            return 0
            ;;
          link-window | move-window | swap-window)
            _get_tmux_window_list
            return 0
            ;;
        esac
        ;;
    -t) case $tmux_command in
          command-prompt | confirm-before| detach-client  |\
          display-panes  | lock-client   | refresh-client |\
          show-messages  | suspend-client)
            _get_tmux_client_list
            return 0
            ;;
          copy-mode     | capture-pane    | choose-buffer | \
          choose-client | choose-tree     | clear-history | \
          clock-mode    | display-message | find-window   | \
          if-shell      | join-pane       | kill-pane     |\
          move-pane     | paste-buffer    | pipe-pane     |\
          resize-pane   | respawn-pane    | run-shell     |\
          select-layout | select-pane     | split-window  |\
          swap-pane     | send-keys       | send-prefix)
            _get_tmux_pane_list
            return 0
            ;;
          attach       | attach-session  | has-session      |\
          kill-session | last-window     | list-clients     |\
          lock-session | rename-session  | switch-client    |\
          list-windows | next-window     | previous-window  |\
          set-option   | show-option     | set-hook         |\
          show-hooks   | set-environment | show-environment |\
          show-hooks)
            _get_tmux_session_list
            return 0
            ;;
          break-pane     | kill-window     | last-pane     |\
          link-window    | move-window     | new-window    |\
          next-layout    | previous-layout | rename-window |\
          respawn-window | rotate-window   | select-window |\
          swap-window    | unlink-window)
            _get_tmux_window_list
            return 0
            ;;
        esac
        ;;
    esac
  fi

  COMPREPLY=($(compgen -W "${commands}" -- ${word_current}))
  return 0
}
complete -F _tmux tmux

# END tmux completion
