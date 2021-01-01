{ pkgs, ... }:

{
  boot.kernelPackages = let
    pkgsPatched = import (pkgs.fetchFromGitHub {
      owner = "morganthomas";
      repo = "nixpkgs";
      rev = "22bda01b8539bbe9e2ca2a8ec99f09d41541e775";
      sha256 = "0jfv7jkydmx5r4q57c71ls1ny1vn1d5258l0gwh1inbzmkf6bhfn";
    }) {};
    linux_5_10_2_pkg = { fetchurl, ... } @ args:
      pkgsPatched.buildLinux (args // rec {
        version = "5.10.2";
        modDirVersion = version;
        src = fetchurl {
          url = "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.2.tar.xz";
          sha256 = "18l1ywp99inm90434fm74w8rjfl4yl974kfcpizg2sp2p8xf311v";
        };
        kernelPatches = [];
      } // (args.argsOverride or {}));
   linux_5_10_2 = pkgs.callPackage linux_5_10_2_pkg {};
   in pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_5_10_2);
}
