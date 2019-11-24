#!/bin/sh

xcrun stapler staple HelloWorld3.app
ditto -c -k --keepParent HelloWorld3.app HelloWorld3.zip