#
# Reminder
# ========
#
# This configuration is not used in the final installed system.
# This only serves to allow the installer to work.
#
{ config, lib, pkgs, ... }:

{
  imports = [
    ../common-configuration.nix
    ./modules/all.nix
  ];
}
