{ config, lib, pkgs }:

pkgs.replaceVarsWith {
  src = ./extlinux-conf-builder.sh;
  isExecutable = true;
  replacements = {
    path = lib.makeBinPath [pkgs.coreutils pkgs.gnused pkgs.gnugrep];
    doSecrets =
      if config.boot.loader.supportsInitrdSecrets
      then "true"
      else "false";
    inherit (pkgs) bash;
  };
}
