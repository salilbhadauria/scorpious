#!/usr/bin/env bash
# Pre-requisites:
# npm install mongodb -g
# npm install east east-mongo -g

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

east --config $DIR/um-mongodb.json --dir $DIR/um-migrations migrate