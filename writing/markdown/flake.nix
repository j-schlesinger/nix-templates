{
  description = "DevShell for Writing Markdown in English";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      lib = {
        mkWritingShell = { extraPkgs ? [ ], extraShellHook ? "" }:
          pkgs.mkShell {
            # uses TexLive, Pandoc and Harper
            # TexLive: https://nixos.wiki/wiki/TexLive
            buildInputs = with pkgs; [
              harper
              pandoc
              markdown-oxide
              proselint
            ] ++ extraPkgs;

            shellHook = ''
              export NIX_PROVIDED_LSPS="harper_ls,markdown_oxide"
              # run additional shellHook from child
              ${extraShellHook}

              echo "🐠 Entering Fish shell..."
              exec fish
            '';
          };
      };
      # if you accidentally run nix develop in the repo
      devShells.default = pkgs.mkShell {
        buildInputs = [ pkgs.hello ];
        shellHook = "echo 'This is the parent repo. Use this as a flake input!'";
      };
    });
}
