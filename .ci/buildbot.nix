{
  inherit (import ../pkgs/top-level/release.nix {
    supportedSystems = [
      "x86_64-linux"
    ];
  }) release-checks;

  # conditioned to nixos/* changes.
  manual-nixos = (import ../nixos/release.nix { }).manual.x86_64-linux;
  # doc/*, lib/*, pkgs/tools/nix/nixdoc/*
  manual-nixpkgs =
    let release = import ../pkgs/top-level/release.nix { };
    in {
      manual = release.manual;
      tests = release.manual.tests;
    };

  # TODO: multi architecture?
  # dev-shell = import ../shell.nix;


  # TODO: this will throw an eval error, it should be moved _inside_ a derivation.
  # check-maintainers-sortedness = import ../maintainers/scripts/check-maintainers-sorted.nix;

  # editorconfig requires git information, e.g. changed files
  # nix parseability requires git information
}
