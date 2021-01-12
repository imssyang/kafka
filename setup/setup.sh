#!/bin/bash

APP=kafka
USER=kafka
GROUP=kafka
HOME=/opt/$APP
SYSD=/etc/systemd/system
SERFILE=kafka.service

init() {
  if [[ ! -d $HOME/logs ]]; then
    mkdir $HOME/logs
  fi

  if [[ ! -d $HOME/tmp ]]; then
    mkdir $HOME/tmp
	mkdir $HOME/tmp/zookeeper
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

deinit() {
  chown -R root:root $HOME

  if [[ -d $HOME/tmp ]]; then
    rm -rf $HOME/tmp
    echo "($APP) delete $HOME/tmp"
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

start() {
  local pid=$(jps -l -m | grep $APP | awk '{print $1}')
  if [[ "x" == "x$pid" ]]; then
    systemctl start $SERFILE
    echo "($APP) $SERFILE start!"
  fi

  show
}

stop() {
  local pid=$(jps -l -m | grep $APP | awk '{print $1}')
  if [[ "x" != "x$pid" ]]; then
    systemctl stop $SERFILE
    echo "($APP) $SERFILE stop!"
  fi

  show
}

show() {
  jps -l -m | grep $APP
}

case "$1" in
  init)
    init
    ;;
  deinit)
    deinit
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  show)
	show
	;;
  *)
    SCRIPTNAME="${0##*/}"
    echo "Usage: $SCRIPTNAME {init|deinit|start|stop|show}"
    exit 3
    ;;
esac

exit 0

# vim: syntax=sh ts=4 sw=4 sts=4 sr noet
