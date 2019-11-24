#!/usr/bin/python2.7

# Copies a file/directory into an app bundle, rewriting dynamic load commands
# to use @rpath instead of absolute paths.
#
# Invoked by the Makefile as:
#   ./copy_bundle.py [source path] [destination path] [destination library directory] [source library directory] [source library directory]...
#
# The source library directories are changed to @rpath in the copied binaries.
# If the resulting binary has any @rpath load commands, this invokes
# install_name_tool to the destination library directory as an rpath to the
# binary.
#
# The goal of this is to copy the given files into the app bundle and make sure
# they can still find their dynamically-linked dependencies when the app bundle
# is moved/installed somewhere else.

import os
import os.path
import subprocess
import sys

import macholib.MachO
import macholib.util

def copy_bundle(src, dest, src_prefixes, dest_prefix):
    src_prefixes = list(map(os.path.abspath, src_prefixes))
    dest_prefix = os.path.abspath(dest_prefix)
    if os.path.isfile(src):
        files = [dest]
        subprocess.call(["cp", src, dest])
    else:
        subprocess.call(["rm", "-rf", dest])
        subprocess.call(["ditto", src, dest])
        subprocess.call(["find", dest, "-type", "l", "-delete"])
        files = macholib.util.iter_platform_files(dest)
    for macho_file in files:
        print(macho_file)
        def changefunc(path):
            if path.startswith("@rpath"):
                return path
            for prefix in src_prefixes:
                if path.startswith(prefix):
                    return "@rpath" + path[len(prefix):]
        os.chmod(macho_file, 0755)
        macho = macholib.MachO.MachO(macho_file)
        rewroteAny = False
        for header in macho.headers:
            if macho.rewriteLoadCommands(changefunc):
                rewroteAny = True
        if rewroteAny:
            old_mode = macholib.util.flipwritable(macho_file)
            try:
                with open(macho_file, 'rb+') as f:
                    for header in macho.headers:
                        f.seek(0)
                        macho.write(f)
                    f.seek(0, 2)
                    f.flush()
                    subprocess.call(["install_name_tool", "-add_rpath", "@loader_path/" + os.path.relpath(dest_prefix, os.path.dirname(macho_file)), macho_file])
            finally:
                macholib.util.flipwritable(macho_file, old_mode)
if __name__ == "__main__":
    copy_bundle(sys.argv[1], sys.argv[2], sys.argv[4:], sys.argv[3])