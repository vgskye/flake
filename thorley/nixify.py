IGNORE_DEFCONFIGS = [
    "CC_IS_GCC",
    "AS_IS_GNU",
    "LD_IS_BFD",
    "CC_CAN_LINK",
    "CC_HAS_ASM_GOTO_OUTPUT",
    "CC_HAS_ASM_GOTO_TIED_OUTPUT",
    "CC_HAS_ASM_INLINE",
    "CC_HAS_NO_PROFILE_FN_ATTR",
    "BT_HCIUART",
    "BT_QCA",
    "CROS_EC",
    "CROS_EC_I2C",
    "CROS_EC_SPI",
    "F2FS_FS",
    "IOSCHED_BFQ",
    "IP_PNP",
    "ISO9660_FS",
    "LOGO",
    "NFT_REJECT_NETDEV",
    "NF_TABLES_BRIDGE",
    "NLS_CODEPAGE_437",
    "NLS_ISO8859_1",
    "NLS_UTF8",
    "UDF_FS",
    "ZRAM",
]

with open("./defconfig.nix", "w") as wf:
    wf.write("""pkgs:
let
    y = pkgs.lib.kernel.yes;
    n = pkgs.lib.kernel.no;
    m = pkgs.lib.kernel.module;
in
{
""")
    with open("./config.aarch64") as f:
        for line in f.readlines():
            if line.startswith("#"):
                continue
            line = line.strip("\n")
            if line == "":
                continue
            name = line.split("=")[0][7:]
            value = line.split("=")[1]
            if value not in "ynm":
                continue
            if name in IGNORE_DEFCONFIGS:
                continue
            print(f'    "{name}" = {value};', file=wf)
    print("}", file=wf)
