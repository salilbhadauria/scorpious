#!/usr/bin/env bash
# Pre-requisites:
# npm install mongodb -g
# npm install east east-mongo -g

DIR=$(dirname ${BASH_SOURCE[0]})

east --config "$DIR/um-mongodb.json" --dir "$DIR/um-migrations migrate"