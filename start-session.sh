#!/bin/bash

session="zpdt"
tmux has-session -t $session 2>/dev/null
if [ $? != 0 ]; then
  # Set up your session
  tmux new-session -A -s $session \; \
        send-keys 'btop' C-m \; \
        split-window -h -l 81 \; \
        send-keys 'read -p "Waiting for MASTER console..." && c3270 -secure localhost:3270' C-m \; \
        splitw -v -p 50 \; \
        send-keys 'read -p "Waiting for secondary console..." && c3270 -secure localhost:3270' C-m \; \
        select-pane -t 0 \; \
        splitw -vl 20 \; \
	send-keys 'alias redraw="tmux send-key -t 2 C-l && tmux send-key -t 3 C-l"' C-m \; \
        send-keys 'awsstart ~/zpdt/zos24-devmap-tmux' C-m '# Press ENTER to IPL. ' C-m 'ipl a80 parm 0a82al' \; \
	set -g mouse on \;
else
	tmux attach-session -t $session
fi

