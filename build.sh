#!/usr/bin/env bash
RUN_NAME="food.app.server"

mkdir -p output/bin
cp script/* output/
chmod +x output/bootstrap.sh

if [ "$BUILD_TYPE" = "offline" -o "$BUILD_TYPE" = "test" ]; then
    go install code.byted.org/bet/go_coverage@tiktok_sg
    go_coverage annotate -main-folder=cmd -skip-files=vendor,thrift_gen,clients,swagger_gen,kitex_gen,test*,cronjob
fi

if [ "${IS_SYSTEM_TEST_ENV}" != "1" ]; then
	go build -v -o output/bin/$RUN_NAME ./
else
	go test -c -covermode=set -o output/bin/"${RUN_NAME}" -coverpkg=./...
fi
