# Hello World! 3rd Edition macOS Software Package

**PLEASE NOTE:** If you're just getting started with the book and want to download the macOS installer, please visit [helloworldbook3.com][book].

This software package includes everything you need to use [Hello World! 3rd Edition][book] on a Mac in an easy-to-use app bundle. You don't need to be an administrator to install it, and you don't need to download Homebrew or run any Terminal commands.

[book]: http://helloworldbook3.com

## Software included

- [Python 3](https://www.python.org), a programming language designed to be easy to learn
- [Qt 5](https://www.qt.io), a library for making graphical user interfaces
- [PyQt](https://riverbankcomputing.com/software/pyqt/intro), a module for using Qt in Python
- [SDL](https://www.libsdl.org), a library for graphics, sound, and input in games
- [Pygame](https://www.pygame.org/), a module for using SDL in Python
- [Tcl/Tk](https://www.tcl.tk), another GUI library needed for IDLE and Easygui
- Telnet, a command-line program for sending data over the Internet (version from [Apple Open Source](https://opensource.apple.com))
- Various other open-source libraries needed by this software

## Compiling this package yourself

**You do not need to do this to use the book -- visit [helloworldbook3.com][book] to download a copy of the software package that's already been compiled for you.**

To compile this software package, you'll need a recent version of macOS and a copy of Xcode. (The command-line tools you get by running `xcode-select --install` won't cut it. You need the full version of Xcode.) Clone a copy of this repository that includes submodules:

```
$ git clone --recursive https://github.com/cp4k/hello-world-3-mac
```

(If you accidentally cloned the repository without submodules, run `git submodule update --init --recursive`.)

Then, run these commands to start compiling the package:

```
$ cd hello-world-3-mac/mac
$ make -j4
```

Make will download a few more files and compile all of the software in parallel. (The `-j4` tells Make to run 4 compilation tasks at once. You might want to make the number bigger or smaller if your computer is especially fast or slow.) The build process will take a while, but when it's done, you should hopefully have an app bundle in `mac/dist/HelloWorld3.app`.