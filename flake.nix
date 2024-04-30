{
  description = "NixOS packaging for TiKV Server and PD";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      tikvBinaryUrl = version: targetArch: targetOs: "https://tiup-mirrors.pingcap.com/tikv-v${version}-${targetOs}-${targetArch}.tar.gz";
      pdBinaryUrl = version: targetArch: targetOs: "https://tiup-mirrors.pingcap.ocom/pd-v${version}-${targetOs}${targetArch}.tar.gz";
    in
    {
      defaultPackage.x86_64-linux =
        with import nixpkgs { system = "x86_64-linux"; };
        stdenv.mkDerivation rec {
          name = "tikv-server-${version}";
          version = "8.0.0";
          src = pkgs.fetchurl {
            url = tikvBinaryUrl version "amd64" "linux";
            sha256 = "sha256-EeGji4xUek3xWfiALR4wy45abam3N0cjM/7BKizeugs=";
          };

          sourceRoot = ".";

          installPhase = ''
            patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) tikv-server
            install -m755 -D tikv-server $out/bin/tikv-server
          '';

          meta = with lib; {
            homepage = "https://tikv.org";
            description = "Distributed, scalable, key value store";
            platforms = platforms.linux;
          };
        };
    };
}
