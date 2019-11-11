#!/usr/bin/python2.7

import os
import subprocess
import sys

import macholib.MachO
import macholib.util

def copy_bundle(src, dest, src_prefix, dest_prefix):
    subprocess.call(["rm", "-rf", dest])
    subprocess.call(["ditto", src, dest])
    subprocess.call(["find", "-type", "l", "-delete", "dest"])
    src_prefix = os.path.abspath(src_prefix)
    dest_prefix = os.path.abspath(dest_prefix)
    for macho_file in macholib.util.iter_platform_files(dest):
        print(macho_file)
        def changefunc(path):
            if path.startswith(src_prefix):
                return "@rpath" + path[len(src_prefix):]
            elif path.startswith("@rpath"):
                return path
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
                    subprocess.call(["install_name_tool", "-add_rpath", os.path.relpath(dest_prefix, os.path.dirname(macho_file)), macho_file])
            finally:
                macholib.util.flipwritable(macho_file, old_mode)
if __name__ == "__main__":
    copy_bundle(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])