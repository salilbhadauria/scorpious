#!/usr/bin/env bash
# Pre-requisites:
# npm install mongodb -g
# npm install east east-mongo -g

east --config baile-mongodb.json --dir baile-migrations migrate