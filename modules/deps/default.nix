{ lib, pkgs, ... }:
let
  # We lock modules by nvfetcher.toml
  # To update modules, run: nix run github:berberman/nvfetcher in deps folder
  sources = ./_sources/generated.nix;
  deps = lib.filterAttrs (_: v: v ? src) (pkgs.callPackage sources { });
  makeRemote = module: "https://github.com/${module.owner}/${module.repo}";
in
{
  modules = deps;
  makeRemote = makeRemote;
  pullRemote = pkgs.writeText "pullRemote.sh" ''
    _pullRemote() {
    local location=$1
    local remote=$2
    local rev=$3
    if [ -d $location ]; then
        echo "$location already exists, skipping..."
        exit 0
    fi
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    ${pkgs.git}/bin/git clone $remote $location
    cd $location && ${pkgs.git}/bin/git checkout $rev
    }
  '';
}
