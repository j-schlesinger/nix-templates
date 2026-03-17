{
  description = "A development shell for writing prose in Markdown";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # points to parent dev env repository 
    writing-toolchain.url = "github:j-schlesinger/nix-templates?dir=writing/markdown";
  };

  outputs = { self, nixpkgs, flake-utils, writing-toolchain }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        mkWritingShell = writing-toolchain.lib.${system}.mkWritingShell;
      in
      {
        devShells.default = mkWritingShell {
          # any non-python packages needed as required by this project
          extraPkgs = with pkgs; [
          ];

          # synchronize the environment on entry, change this to rye if not upgraded to uv
          extraShellHook = ''
          '';
        };
      });
}
