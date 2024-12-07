#!/bin/bash
java \
     -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dsun.java2d.uiScale=2 \
     -jar Mars.jar "$@"
