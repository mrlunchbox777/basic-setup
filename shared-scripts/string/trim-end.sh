#! /usr/bin/env bash

sed_string="s/.\{$2\}$//"
trimmed_string=$(sed "$sed_string" <<<"$1")
echo "$trimmed_string"
