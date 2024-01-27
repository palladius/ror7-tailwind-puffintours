#!/bin/bash


SEARCH_TERM=""


ack -r \
    --ignore-dir=tmp/ \
    --ignore-dir=log/ \
    --ignore-dir=app/assets/builds/ \
    --ignore-dir=public/assets/ \
    fetch-api-data .
    # | less
