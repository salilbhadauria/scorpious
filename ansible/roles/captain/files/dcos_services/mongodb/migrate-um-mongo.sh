#!/usr/bin/env bash
# Pre-requisites:
# npm install mongodb -g
# npm install east east-mongo -g

east --config um-mongodb.json --dir um-migrations migrate