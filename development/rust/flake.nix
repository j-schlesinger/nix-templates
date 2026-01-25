{
  description = "A dev shell parent for Rust developnent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        lib = {
          mkRustShell = { extraPkgs ? [ ], extraShellHook ? "" }:
            pkgs.mkShell {
              buildInputs = with pkgs; [
                cargo
                rustc
                bacon
                clippy
                rust-analyzer
                rust-bin.beta.latest.default
                llvmPackages.clang
                llvmPackages.libclang
              ] ++ extraPkgs;

              shellHook = ''
                export LIBCLANG_PATH="{$pkgs.llvmPackages.libclang}/lib";
                if [ ! -f "Cargo.toml" ]; then
                  echo "cargo.toml not initialized, creating..."
                  cargo init
                fi

                # run additional shellHook from child
                ${extraShellHook}

                if [[ $(ps -p $PPID -o comm=) != "fish" ]]; then
                  echo "🐠 Entering Fish shell..."
                  exec fish
                fi 
              '';
            };
        };
      });
}
