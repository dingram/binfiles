#!/bin/sh
################################################################################
# This program is released under a Creative Commons
# Attribution-NonCommerical-ShareAlike2.5 License.
#
# For more information, please see
#   http://creativecommons.org/licenses/by-nc-sa/2.5/
#
# You are free:
#
# * to copy, distribute, display, and perform the work
# * to make derivative works
#
# Under the following conditions:
#   Attribution:   You must attribute the work in the manner specified by the
#                  author or licensor.
#   Noncommercial: You may not use this work for commercial purposes.
#   Share Alike:   If you alter, transform, or build upon this work, you may
#                  distribute the resulting work only under a license identical
#                  to this one.
#
# * For any reuse or distribution, you must make clear to others the license
#   terms of this work.
# * Any of these conditions can be waived if you get permission from the
#   copyright holder.
#
# Your fair use and other rights are in no way affected by the above.
################################################################################
#
# Harvests all SSH keys from machines

function scan_section () {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Parameter 1 or 2 is zero length"
  else
    for n in `seq -w 1 $2`; do
      h=`host ${1}${n} | cut -d' ' -f4`
      ilist=`echo -e "${ilist}\n${1}${n}\n${h}"`
    done
    echo "${ilist}" | ssh-keyscan -f - -t rsa,dsa >> ~/.ssh/known_hosts
  fi
}

print_header() {
	echo -e "$*"
}

# Lab 219
print_header "Harvesting lab 219"
print_header "vertex 1-61"
scan_section "vertex" "61"
print_header "glyph 1-32"
scan_section "glyph" "32"
print_header "stream 1-6"
scan_section "stream0" "6"
#scan_section "media0" "6"
#scan_section "synapse" "10"

# Lab 210
print_header "Harvesting lab 210"
print_header "fusion 1-13"
scan_section "fusion" "13"
print_header "quantum 1-17"
scan_section "quantum" "17"
print_header "sync 1-12"
scan_section "sync" "12"
#print_header "sync 1-20"
#scan_section "sync" "28" "25"

# Lab 206
print_header "Harvesting lab 206"
# scan_section "sync" "24" "13"
print_header "corona 1-62"
scan_section "corona" "62"
print_header "dynamic 1-32"
scan_section "dynamic" "32"

# Lab 202
print_header "Harvesting lab 202"
print_header "pixel 1-44"
scan_section "pixel" "44"
print_header "texel 1-44"
scan_section "texel" "44"
