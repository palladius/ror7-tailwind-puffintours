#!/bin/bash


SEARCH_TERM="${1:-fetch-api-data}"


time ack -r \
    --ignore-dir=tmp/ \
    --ignore-dir=log/ \
    --ignore-dir=app/assets/builds/ \
    --ignore-dir=public/assets/ \
    fetch-api-data .
    # | less

# Oppure semplicemente: https://github.com/ggreer/the_silver_searcher
# $ brew install the_silver_searcher
# $ echo app/assets/builds/ >> .ignore
echo Silver Surfer:
time ag "$SEARCH_TERM" .
