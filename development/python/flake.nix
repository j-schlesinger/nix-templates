{
  description = "DevShell toolchain for Python";

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
        mkPythonShell = { pythonPackage, extraPkgs ? [ ], extraShellHook ? "" }:
          pkgs.mkShell {
            buildInputs = with pkgs; [
              uv # for virtual environment and project management
              rye # Legacy, use this if you haven't yet migrated to uv
              stdenv.cc.cc.lib # Provides libstdc++.so
              llvmPackages.clang # Provides clang libraries
              llvmPackages.libclang # Provides libclang
              pkg-config
              # LSPs 
              pyright
              ruff
              harper
              pythonPackage
            ] ++ extraPkgs;

            shellHook = ''
              export NIX_PROVIDED_LSPS="pyright,ruff,harper_ls"
              export LIBCLANG_PATH="{$pkgs.llvmPackages.libclang}/lib";
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath extraPkgs}:$LD_LIBRARY_PATH"
              # prevent rye/uv from installing themselves 
              export RYE_PY_BIN="${pythonPackage}/bin/python"
              export UV_PYTHON="${pythonPackage}/bin/python"
              if [ ! -f "pyproject.toml" ]; then
                echo "Pyproject not initialized, creating..."
                uv init
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
      # if you accidentally run nix develop in the repo
      devShells.default = pkgs.mkShell {
        buildInputs = [ pkgs.hello ];
        shellHook = "echo 'This is the parent repo. Use this as a flake input!'";
      };
    });
}
