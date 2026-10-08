#!/usr/bin/env python3
import os
import sys
from pathlib import Path

DEFAULT_APPEND_FLAGS = [
    "-Wno-error", "-Wno-unused-command-line-argument",
    "-fno-stack-protector", "-fno-plt",
    "-flto=full", "-fwhole-program-vtables", "-fvirtual-function-elimination", "-Wl,--lto-O3,--lto-partitions=1",
    "-ffunction-sections", "-fdata-sections", "-Wl,--gc-sections",
    "-fPIC",
    "-g0", "-s",
    "-fuse-ld=lld", "-Wl,-O2,--icf=all,--as-needed,--sort-common,--pack-dyn-relocs=relr,-mllvm,-enable-ext-tsp-block-placement=1",
]


def split_env_flags(key):
    value = os.getenv(key, "").strip()
    return value.split() if value else []


def find_last_optimization_flag(args):
    last_flag = None
    for arg in args:
        if arg.startswith("-O"):
            last_flag = arg
    return last_flag


class CompilerWrapper:
    def __init__(self, argv):
        self.argv0 = argv[0]
        self.args = argv[1:]
        compiler_name = self.detect_compiler_name(Path(self.argv0).name)
        self.real_compiler = self.resolve_real_compiler(compiler_name)

    @staticmethod
    def detect_compiler_name(invocation_name):
        if invocation_name.endswith("-clang++"):
            return "clang++"
        if invocation_name.endswith("-clang"):
            return "clang"
        return invocation_name

    @staticmethod
    def resolve_real_compiler(compiler_name):
        bin_dir = Path(__file__).resolve().parent
        backup = bin_dir / f"{compiler_name}_"
        if backup.exists():
            return backup
        return bin_dir / compiler_name

    def check_target(self):
        i = len(self.args) - 1
        while i >= 0:
            arg = self.args[i]
            if arg.startswith("-target=") or arg.startswith("--target="):
                value = arg.split("=", 1)[1]
                return value.startswith("aarch64")
            elif arg == "-target" or arg == "--target":
                if i + 1 < len(self.args):
                    return self.args[i + 1].startswith("aarch64")
                return False
            i -= 1
        return False

    def should_skip_customization(self):
        return (
            os.getenv("NDK_WRAPPER_DISABLED") == "1" or
            len(self.args) <= 2 or
            "-cc1" in self.args or
            "-cc1as" in self.args or
            not self.check_target()
        )

    def build_prepend_flags(self):
        return [*split_env_flags("NDK_WRAPPER_PREPEND")]

    def build_append_flags(self):
        append_flags = []
        env_append_flags = split_env_flags("NDK_WRAPPER_APPEND")
        if os.getenv("NDK_WRAPPER_DISABLED") != "2":
            effective_opt = find_last_optimization_flag(self.args)
            if effective_opt != "-O0":
                append_flags.extend(["-O3", "-ffast-math", "-lm"])
            append_flags.extend(DEFAULT_APPEND_FLAGS)
        append_flags.extend(env_append_flags)
        return append_flags

    def parse_custom_flags(self):
        if self.should_skip_customization():
            return
        self.args = self.build_prepend_flags() + self.args + self.build_append_flags()

    def invoke_compiler(self):
        self.parse_custom_flags()
        execargs = [self.argv0, *self.args]

        if os.getenv("WRAPPER_WRITE_LOG"):
            with open("/tmp/ndk-wrapper-log.txt", "a", encoding="utf-8") as log_file:
                log_file.write(" ".join(execargs) + "\n")

        os.execv(self.real_compiler, execargs)


def main(argv):
    wrapper = CompilerWrapper(argv)
    wrapper.invoke_compiler()


if __name__ == "__main__":
    main(sys.argv)
