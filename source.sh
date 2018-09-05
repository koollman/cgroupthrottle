#!/bin/sh

while true; do
    sensors | awk '/power1/{print int($2)*1000}'
    sleep 10
done
