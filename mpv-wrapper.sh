#!/usr/bin/env bash
# requires a notification daemon, mpv and notify-send along with xclip or wl-paste
# commented out section requires curl

# first check if there an argument if so attempt to play that
# if not, check the copy buffers
if [[ -n "$1" ]] ; then
	BUFFER=$1
else
if [[ $XDG_SESSION_TYPE == wayland ]] ; then
	PASTE_PRIMARY="wl-paste --primary"
	PASTE_CLIPBOARD="wl-paste"
fi

if [[ $XDG_SESSION_TYPE == x11 ]] ; then
	PASTE_PRIMARY="xclip -out -selection primary"
	PASTE_CLIPBOARD="xclip -out -selection clipboard"
fi

# crude check to see which copy buffer has a URL, as some application do not copy to XA_PRIMARY.
BUFFER=$($PASTE_PRIMARY)
if ! [[ $BUFFER =~ ^http ]] ; then
	BUFFER=$($PASTE_CLIPBOARD)
fi
fi
# mpv now supports 301s, leaving commented out for possible future use cases
#if [[ $(curl --output /dev/null --silent --head --write-out "%{response_code}" "$BUFFER" )  == 301 ]]
#then
#	BUFFER=$(curl --output /dev/null --silent --head --write-out "%{redirect_url}" "$BUFFER" )
#fi

# --force-window is needed for audio only, without it there is no playback controls
if ! mpv --no-terminal --force-window "$BUFFER" ; then
# display a warning if play back failed
	notify-send --app-name=mpv --icon=mpv mpv "playback failed"
fi
