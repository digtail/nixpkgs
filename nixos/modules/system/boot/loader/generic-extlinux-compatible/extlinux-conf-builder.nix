{ config, pkgs }:

pkgs.substituteAll {
  src = ./extlinux-conf-builder.sh;
  isExecutable = true;
  path = [pkgs.coreutils pkgs.gnused pkgs.gnugrep];
  doSecrets =
    if config.boot.loader.supportsInitrdSecrets
    then "true"
    else "false";
  inherit (pkgs) bash;
}
