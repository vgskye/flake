import json
from pathlib import Path
from shutil import copy
import subprocess
import sys
import tempfile
import lzma

its_fragment = """
/dts-v1/;

/ {
    description = "%DESC%";
    images {
        kernel-1{
            description = "kernel";
            data = /incbin/("%KERN_PATH%");
            type = "kernel_noload";
            arch = "arm64";
            os = "linux";
            compression = "lzma";
            load = <0>;
            entry = <0>;
        };
        ramdisk-1 {
            description = "ramdisk";
            data = /incbin/("%INITRD_PATH%");
            type = "ramdisk";
            arch = "arm64";
            os = "linux";
            compression = "none";
            hash-1 {
                algo = "sha1";
            };
        };
%FDT_FRAG%
    };
    configurations {
        default = "conf-0";
%CONF_FRAG%
    };
};
"""

fdt_fragment = """
        fdt-{0} {{
            description = "{1}";
            data = /incbin/("{2}");
            type = "flat_dt";
            arch = "arm64";
            compression = "none";
            hash-1 {{
                algo = "sha1";
            }};
        }};
"""

conf_fragment = """
        conf-{0} {{
            kernel = "kernel-1";
            fdt = "fdt-{0}";
            ramdisk = "ramdisk-1";
        }};
"""

with open(sys.argv[1] + "/boot.json") as f:
    bootspec = json.load(f)
    real = bootspec["org.nixos.bootspec.v1"]
    cmdline = " ".join([f"init={real['init']}", "kern_guid=%U"] + real["kernelParams"])
    dtbpath = Path(real["toplevel"] + "/dtbs")
    fdt_fragment_built = ""
    conf_fragment_built = ""
    print(cmdline)
    for i, path in enumerate(dtbpath.glob("**/*.dtb")):
        fdt_fragment_built += fdt_fragment.format(i, path.name, path)
        conf_fragment_built += conf_fragment.format(i)
    with tempfile.TemporaryDirectory() as tmpdir:
        print(tmpdir)
        built = (
            its_fragment.replace("%DESC%", real["label"])
            .replace("%KERN_PATH%", tmpdir + "/kernel.lzma")
            .replace("%INITRD_PATH%", real["initrd"])
            .replace("%FDT_FRAG%", fdt_fragment_built)
            .replace("%CONF_FRAG%", conf_fragment_built)
        )
        with open(real["kernel"], "rb") as kernf:
            with lzma.LZMAFile(
                tmpdir + "/kernel.lzma", "wb", format=lzma.FORMAT_ALONE
            ) as lzmaf:
                lzmaf.write(kernf.read())
        with open(tmpdir + "/kernel.its", "w") as itsf:
            itsf.write(built)
        with open(tmpdir + "/cmdline", "w") as cmdlinef:
            cmdlinef.write(cmdline)
        with open(tmpdir + "/bootloader.bin", "wb") as blf:
            blf.write(b"\0" * 512)
        print("making image")
        subprocess.run(
            ["mkimage", "-q", "-f", tmpdir + "/kernel.its", tmpdir + "/vmlinux.uimg"],
            check=True,
        )
        subprocess.run(
            [
                "futility",
                "vbutil_kernel",
                "--version",
                "1",
                "--bootloader",
                tmpdir + "/bootloader.bin",
                "--vmlinuz",
                tmpdir + "/vmlinux.uimg",
                "--arch",
                "aarch64",
                "--keyblock",
                "/vboot_keys/kernel.keyblock",
                "--signprivate",
                "/vboot_keys/kernel_data_key.vbprivk",
                "--config",
                tmpdir + "/cmdline",
                "--pack",
                tmpdir + "/kpart.bin",
            ],
            check=True,
        )
        if "--mkpart" in sys.argv:
            copy(tmpdir + "/kpart.bin", "kpart.bin")
        else:
            subprocess.run(
                ["depthchargectl", "/dev/mmcblk1", "install", tmpdir + "/kpart.bin"],
                check=True,
            )
