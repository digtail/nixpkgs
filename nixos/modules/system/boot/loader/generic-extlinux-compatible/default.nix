{ config, lib, pkgs, ... }:

with lib;

let
  blCfg = config.boot.loader;
  dtCfg = config.hardware.deviceTree;
  cfg = blCfg.generic-extlinux-compatible;

  timeoutStr = if blCfg.timeout == null then "-1" else toString blCfg.timeout;

  # The builder used to write during system activation
  builder = import ./extlinux-conf-builder.nix { inherit config pkgs; };
  # The builder exposed in populateCmd, which runs on the build architecture
  populateBuilder = import ./extlinux-conf-builder.nix { inherit config; pkgs = pkgs.buildPackages; };
in
{
  options = {
    boot.loader.generic-extlinux-compatible = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Whether to generate an extlinux-compatible configuration file
          under `/boot/extlinux.conf`.  For instance,
          U-Boot's generic distro boot support uses this file format.

          See [U-boot's documentation](https://u-boot.readthedocs.io/en/latest/develop/distro.html)
          for more information.
        '';
      };

      useGenerationDeviceTree = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Whether to generate Device Tree-related directives in the
          extlinux configuration.

          When enabled, the bootloader will attempt to load the device
          tree binaries from the generation's kernel.

          Note that this affects all generations, regardless of the
          setting value used in their configurations.
        '';
      };

      configurationLimit = mkOption {
        default = 20;
        example = 10;
        type = types.int;
        description = ''
          Maximum number of configurations in the boot menu.
        '';
      };

      enableSecrets = mkOption {
        default = false;
        description = ''
          Enables support for {option}`boot.initrd.secrets`. This requires your
          extlinux bootloader to have support for the initramfs consisting of
          concatenated cpio archives. Not all boards / extlinux implementation
          work with this. If this works or does not work on your setup, please
          report your findings on
          https://github.com/NixOS/nixpkgs/issues/247145.
        '';
        example = true;
        type = types.bool;
      };

      populateCmd = mkOption {
        type = types.str;
        readOnly = true;
        description = ''
          Contains the builder command used to populate an image,
          honoring all options except the `-c <path-to-default-configuration>`
          argument.
          Useful to have for sdImage.populateRootCommands
        '';
      };

    };
  };

  config = let
    builderArgs = "-g ${toString cfg.configurationLimit} -t ${timeoutStr}"
      + lib.optionalString (dtCfg.name != null) " -n ${dtCfg.name}"
      + lib.optionalString (!cfg.useGenerationDeviceTree) " -r";
  in
    mkIf cfg.enable {
      system.build.installBootLoader = "${builder} ${builderArgs} -c";
      system.boot.loader.id = "generic-extlinux-compatible";

      boot.loader.generic-extlinux-compatible.populateCmd = "${populateBuilder} ${builderArgs}";
      boot.loader.supportsInitrdSecrets = lib.mkDefault cfg.enableSecrets;
    };
}
