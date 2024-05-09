{
  description = "Flake for develop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system;};
        deps = with pkgs; [
					vim
					tmux
					yazi
          git
					man
					ccache

          mill
          dtc
					boost
          gnumake autoconf automake
          cmake ninja
          pkgsCross.riscv64-embedded.buildPackages.gcc
          pkgsCross.riscv64-embedded.buildPackages.gdb
          verilator cmake ninja
          openocd
          circt
          spike

					llvm_17
					SDL2
					readline
        ];
      in
        {
          legacyPackages = pkgs;
          devShell = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } {
          buildInputs = deps;
          SPIKE_ROOT = "${pkgs.spike}";
          RV64_TOOLCHAIN_ROOT = "${pkgs.pkgsCross.riscv64-embedded.buildPackages.gcc}";
          shellHook = ''
						export PATH=$PATH:$SPIKE_ROOT/bin:$RV64_TOOLCHAIN_ROOT/bin
						alias ra='yazi'
          '';
          };
        }
      )
    // { inherit inputs;};
}
