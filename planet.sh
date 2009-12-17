#!/bin/bash
#xplanet-gnome.sh shell script v0.2
#shows Earth on your Gnome desktop with current lighting conditions,i.e. day and night

DELAY=10m

PREFIX=$HOME/
OUTPUT=xplanet.png
APPEND=2

GEOMETRY=1280x1024
LONGITUDE=0
LATITUDE=51
#london is at 51 0
#default is no projection,i.e. render a globe
#rectangular is the flat world map. also try ancient, azimuthal,  mercator,..
#PROJECTION=rectangular

#rename background image so Gnome realises image has changed - thx to dmbasso

if [ -e "$PREFIX$OUTPUT" ]; then
   rm "$PREFIX$OUTPUT"
   OUTPUT="$APPEND$OUTPUT"
else
   rm "$PREFIX$APPEND$OUTPUT"
fi

if [ -z $PROJECTION ]; then 
xplanet -body earth -num_times 1 -output "$PREFIX$OUTPUT" -geometry $GEOMETRY -longitude $LONGITUDE -latitude $LATITUDE
else
xplanet -body earth -num_times 1 -output "$PREFIX$OUTPUT" -geometry $GEOMETRY -longitude $LONGITUDE -latitude $LATITUDE -projection $PROJECTION
fi

#update Gnome backgound
#gconftool-2 -t str -s /desktop/gnome/background/picture_filename "$PREFIX$OUTPUT"
#Esetroot "$PREFIX$OUTPUT"
hsetroot -center "$PREFIX$OUTPUT"

#echo "Updated at" `date --iso-8601=seconds`
#echo  "$PREFIX$OUTPUT"

sleep $DELAY
exec $0
