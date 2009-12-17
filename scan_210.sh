#!/bin/sh
#
# Scans lab machines searching for logged in users

function scan_section () {
    if [[ -z "$1" || -z "$2" ]]
    then
	echo "Parameter 1 or 2 is zero length"
    else
	for n in `seq -w 1 $2`;
	    do echo "$1$n:"
            if ping -c 1 -W 1 $1$n > /dev/null
	    then
		ssh -A -q -n -x -2 $1$n /bin/sh -c finger -s
	    else
		echo "  (Host down)"
	    fi
	    echo
	done;
    fi
}

echo "Users logged in (generated at `date`)"
echo "-----------------------------------------------------------"
echo

# Lab 219
#scan_section "vertex" "61"
#scan_section "glyph" "32"
#scan_section "active" "20"
#scan_section "media0" "6"
#scan_section "synapse" "10"

# Lab 210
scan_section "fusion" "13"
scan_section "quantum" "17"
scan_section "sync" "12"
scan_section "sync" "28" "25"

# Lab 206
#scan_section "sync" "24" "13"
#scan_section "dynamic" "32"

# Lab 202
#scan_section "texel" "44"
