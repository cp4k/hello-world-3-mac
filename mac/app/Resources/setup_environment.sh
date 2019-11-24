#!/bin/sh

#  setup_environment.sh
#  HelloWorld3
#
#  Created by Carter Sande on 8/18/19.

clear

contents=$(cd "$(dirname $0)/.."; pwd)
export TCL_LIBRARY="$contents/Frameworks/Tcl.framework/Versions/8.6/Resources/Scripts"
export TK_LIBRARY="$contents/Frameworks/Tk.framework/Versions/8.6/Resources/Scripts"
export QT_PLUGIN_PATH="$contents/PlugIns"
export PATH="$contents/MacOS:$contents/Frameworks/Python.framework/Versions/3.7/bin:$PATH"
cd ~/Desktop

echo '================================================================================'
echo ' This special terminal window has been set up to use Python and Telnet from the'
echo '               Hello World! Third Edition software package. Enjoy!'
echo '================================================================================'
echo

if type "zsh" > /dev/null; then
  exec /usr/bin/env zsh
fi
export PS1=\w\$
exec /usr/bin/env bash