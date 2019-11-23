#define _GNU_SOURCE
#include <libgen.h>
#include <mach-o/dyld.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// Concatenate the given strings, allocating memory to store the result.
// The caller has to free the memory, but we don't really care about leaks
// in this program because it unconditionally execs.
inline char *concat(const char *a, const char *b) {
    char *result = NULL;
    asprintf(&result, "%s%s", a, b);
    return result;
}

int main(int argc, char *argv[]) {
    char currentExecutablePath[4096];
    unsigned int bufsize = 4096;
    if (_NSGetExecutablePath(currentExecutablePath, &bufsize) != 0) {
        return 1;
    }
    
    const char *contents = realpath(
        concat(
            dirname(currentExecutablePath),
            "/.."
        ),
        NULL
    );
    
    char *python = concat(contents, "/Frameworks/Python.framework/Versions/3.7/Resources/Python.app/Contents/MacOS/Python");
    argv[0] = python;
    
    return execv(python, argv);
}