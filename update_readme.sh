#!/bin/bash

head -n200 ax_lua.m4 | grep "^#" | sed -e "s;^# ;;" -e "s;^#;;" >README
