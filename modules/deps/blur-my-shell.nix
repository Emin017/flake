# Blur my Shell built from upstream master, pinned in nvfetcher.toml.
# nixpkgs ships the extensions.gnome.org release, which still draws a square
# blur around notification banners on GNOME 50.
{
  stdenvNoCC,
  gnumake,
  glib,
  gettext,
  libxml2,
  gnome-shell,
  unzip,
  source,
}:
stdenvNoCC.mkDerivation rec {
  inherit (source) pname src;
  version = "0-unstable-${source.date}";

  nativeBuildInputs = [
    gnumake
    glib
    gettext
    libxml2 # xmllint, for xml-stripblanks in the gresource
    gnome-shell # gnome-extensions pack
    unzip
  ];

  buildPhase = ''
    runHook preBuild
    make build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    dir=$out/share/gnome-shell/extensions/${passthru.extensionUuid}
    mkdir -p $dir
    unzip -q build/${passthru.extensionUuid}.shell-extension.zip -d $dir
    glib-compile-schemas $dir/schemas
    runHook postInstall
  '';

  passthru = {
    extensionUuid = "blur-my-shell@aunetx";
    extensionPortalSlug = "blur-my-shell";
  };
}
