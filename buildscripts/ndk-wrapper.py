#!/usr/bin/python3
import os
import sys
from pathlib import Path

class CompilerWrapper:
    def __init__(self, argv):
        self.argv0 = argv[0]
        self.args = argv[1:]
        wrapper_name = Path(argv[0]).name.rsplit(sep='-', maxsplit=1)
        self.target = wrapper_name[0]
        self.real_compiler = Path(__file__).resolve().parent / wrapper_name[1]

    def parse_custom_flags(self):
        if len(self.args) > 0 and self.args[0] == "-cc1":
            return
        self.args = [a for a in self.args if not a.startswith("-march=")]
        prepend_flags = [f"--target={self.target}"]
        append_flags = ["-w", "-g0"]
        append_flags += ["-O3", "-ffast-math", "-fno-stack-protector", "-fno-plt", "-flto=full"]
        append_flags += ["-fPIC"]
        append_flags += ["-s","-fuse-ld=lld", "-lm"]
        env_prepend = os.getenv("NDK_WRAPPER_PREPEND")
        if env_prepend:
            prepend_flags += env_prepend.split()
        env_append = os.getenv("NDK_WRAPPER_APPEND")
        if env_append:
            append_flags += env_append.split()
        self.args = prepend_flags + self.args + append_flags

    def invoke_compiler(self):
        self.parse_custom_flags()
        execargs = [self.argv0] + self.args
        if os.getenv("WRAPPER_WRITE_LOG"):
            with open("/tmp/ndk-wrapper-log.txt", "a") as log_file:
                log_file.write(" ".join(execargs) + "\n")

        os.execv(self.real_compiler, execargs)


def main(argv):
    cw = CompilerWrapper(argv)
    cw.invoke_compiler()

if __name__ == "__main__":
    main(sys.argv)
