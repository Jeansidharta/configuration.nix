#!/usr/bin/env bash

rm target 2> /dev/null
ln -s "./$(hostname)" target
