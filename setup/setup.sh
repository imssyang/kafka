#!/bin/bash

APP=kafka
USER=root
GROUP=root
HOME=/opt/$APP
SYSD=/etc/systemd/system
SERFILE=kafka.service

initialize() {
  if [[ ! -d $HOME/data ]]; then
    mkdir $HOME/data
  fi

  if [[ ! -d $HOME/logs ]]; then
    mkdir $HOME/logs
  fi

  if [[ ! -d $HOME/run ]]; then
    mkdir $HOME/run
  fi

  chown -R $GROUP:$USER $HOME
  chmod 755 $HOME

  if [[ ! -s $SYSD/$SERFILE ]]; then
    ln -s $HOME/setup/$SERFILE $SYSD/$SERFILE
    systemctl enable $SERFILE
    echo "($APP) create symlink: $SYSD/$SERFILE --> $HOME/setup/$SERFILE"
  fi

  systemctl daemon-reload
}

deinitialize() {
  chown -R root:root $HOME

  if [[ -d $HOME/run ]]; then
    rm -rf $HOME/run
    echo "($APP) delete $HOME/run"
  fi

  if [[ -d $HOME/logs ]]; then
    rm -rf $HOME/logs
    echo "($APP) delete $HOME/logs"
  fi

  if [[ -s $SYSD/$SERFILE ]]; then
    systemctl disable $SERFILE
    rm -rf $SYSD/$SERFILE
    echo "($APP) delete symlink: $SYSD/$SERFILE"
  fi
}

daemon_start() {
  local pid=$(jps -l -m | grep $APP | awk '{print $1}')
  if [[ "x" == "x$pid" ]]; then
    systemctl start $SERFILE
    echo "($APP) $SERFILE start!"
  fi

  daemon_show
}

daemon_stop() {
  local pid=$(jps -l -m | grep $APP | awk '{print $1}')
  if [[ "x" != "x$pid" ]]; then
    systemctl stop $SERFILE
    echo "($APP) $SERFILE stop!"
  fi

  daemon_show
}

daemon_show() {
  jps -l -m | grep $APP
}

case "$1" in
  init)
    initialize
    ;;
  deinit)
    deinitialize
    ;;
  start)
    daemon_start
    ;;
  stop)
    daemon_stop
    ;;
  show)
	daemon_show
	;;
  *)
    SCRIPTNAME="${0##*/}"
    echo "Usage: $SCRIPTNAME {init|deinit|start|stop|show}"
    exit 3
    ;;
esac

exit 0

# vim: syntax=sh ts=4 sw=4 sts=4 sr noet