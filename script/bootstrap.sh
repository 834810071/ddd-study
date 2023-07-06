#!/usr/bin/env bash
CURDIR=$(cd $(dirname $0); pwd)

if [ "X$1" != "X" ]; then
    RUNTIME_ROOT=$1
else
    RUNTIME_ROOT=${CURDIR}
fi

if [ "X$RUNTIME_ROOT" == "X" ]; then
    echo "There is no RUNTIME_ROOT support."
    echo "Usage: ./bootstrap.sh $RUNTIME_ROOT"
    exit -1
fi

PORT=$2

RUNTIME_CONF_ROOT=$RUNTIME_ROOT/conf
RUNTIME_LOG_ROOT=$RUNTIME_ROOT/log

if [ ! -d $RUNTIME_LOG_ROOT/app ]; then
    mkdir -p $RUNTIME_LOG_ROOT/app
fi

if [ ! -d $RUNTIME_LOG_ROOT/rpc ]; then
    mkdir -p $RUNTIME_LOG_ROOT/rpc
fi

PRODUCT=$(cd $CURDIR; python -c "import settings; print (settings.PRODUCT)")
SUBSYS=$(cd $CURDIR; python -c "import settings; print (settings.SUBSYS)")
MODULE=$(cd $CURDIR; python -c "import settings; print (settings.MODULE)")

if [ -z "$PRODUCT" ] || [ -z "$SUBSYS" ] || [ -z "$MODULE" ]; then
    echo "Support PRODUCT SUBSYS MODULE PORT in settings.py"
    exit -1
fi

if [ "$IS_HOST_NETWORK" == "1" ]; then
    export RUNTIME_SERVICE_PORT=$PORT0
    export RUNTIME_DEBUG_PORT=$PORT1
fi

BinaryName=${PRODUCT}.${SUBSYS}.${MODULE}

export HERTZ_LOG_DIR=$RUNTIME_LOG_ROOT
CONF_DIR=$CURDIR/conf/

args="-conf-dir=$CONF_DIR -log-dir=$HERTZ_LOG_DIR"
if [ "X$PORT" != "X" ]; then
    args+=" -port=$PORT"
fi

export KITEX_RUNTIME_ROOT=$RUNTIME_ROOT
export KITEX_CONF_FILE="kitex.yml"
export KITEX_CONF_DIR="$CURDIR/conf"
export KITEX_LOG_DIR="$RUNTIME_ROOT/log"

if [ ! -d "$KITEX_LOG_DIR/app" ]; then
    mkdir -p "$KITEX_LOG_DIR/app"
fi

if [ ! -d "$KITEX_LOG_DIR/rpc" ]; then
    mkdir -p "$KITEX_LOG_DIR/rpc"
fi

echo "$CURDIR/bin/${BinaryName} $args"

exec $CURDIR/bin/${BinaryName} $args
