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
        if len(self.args) == 0 or "-cc1" in self.args or "-cc1as" in self.args:
            return
        prepend_flags = [f"--target={self.target}"]
        append_flags = []
        if not os.getenv("NDK_WRAPPER_DISABLED"):
            self.args = [a for a in self.args if not a.startswith("-march=")]
            append_flags += ["-Wno-error", "-Wno-unused-command-line-argument"]
            append_flags += ["-O3", "-fno-stack-protector", "-fno-plt"]
            append_flags += ["-ffast-math", "-lm"]
            append_flags += ["-flto=full", "-fwhole-program-vtables", "-fvirtual-function-elimination", "-Wl,--lto-O3,--lto-partitions=1"]
            append_flags += ["-ffunction-sections", "-fdata-sections", "-Wl,--gc-sections"]
            append_flags += ["-fPIC"]
            append_flags += ["-g0", "-s"]
            append_flags += ["-fuse-ld=lld", "-Wl,-O2,--icf=all,--as-needed,--sort-common,-mllvm,-enable-ext-tsp-block-placement=1"]
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
