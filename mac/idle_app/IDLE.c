//
//  IDLE.m
//  HelloWorld3
//
//  Created by Carter Sande on 8/18/19.
//  Copyright © 2019 Manning Publications Inc. All rights reserved.
//

#define _GNU_SOURCE
#include <libgen.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// Concatenate the given strings, allocating memory to store the result.
// The caller has to free the memory, but we don't really care about leaks
// in this program because it unconditionally execs.
char *concat(const char *a, const char *b) {
    char *result = NULL;
    asprintf(&result, "%s%s", a, b);
    return result;
}

// Based (loosely!) on the Python script embedded in the real Python's IDLE.app.
// But this one needs to use a *relative* path to invoke Python (since the
// app bundle containing Python.framework could be installed anywhere) and can't
// use aliases or symlinks.
//
// The reason this isn't just a shell script is because creating an app bundle
// whose main executable has a #!/bin/sh shebang confuses macOS into applying
// the sandbox rules for the /bin/sh executable, which prevents us from
// accessing files. Grrr!
int main(int argc, char * argv[]) {
    if (argc > 100) {
        return 1;
    }
    char *newArgv[104] = {0};
    int newArgc = 0;

    char *pythondir = realpath(
        concat(
            dirname(argv[0]),
            "/../../../../Frameworks/Python.framework/Versions/3.7/Resources/Python.app/Contents/MacOS/"
        ),
        NULL
    );
    // Change directory into the Python framework. This is needed by Tk,
    // otherwise it just shows a black screen. (I don't know why.)
    chdir(pythondir);

    newArgv[0] = argv[0];
    newArgv[1] = "-c";
    newArgv[2] = "import os, sys, idlelib.pyshell; os.chdir(sys.argv.pop(1)); idlelib.pyshell.main();";
    newArgv[3] = getenv("HOME");
    newArgc = 4;
    for (int i = 1; i < argc; i++) {
        if ((argv[i][0] == '-') && (argv[i][1] == 'p') && (argv[i][2] == 's') &&
            (argv[i][3] == 'n') && (argv[i][4] == '_')) {
            // Supposedly, macOS will sometimes add a "-psn_XYZ" argument
            // to the executable. This confuses IDLE, so remove it.
            continue;
        }
        newArgv[newArgc] = argv[i];
        newArgc++;
    }

    setenv("PYTHONEXECUTABLE", concat(pythondir, "/Python"), 1);

    return execv(concat(pythondir, "/Python"), newArgv);
}
