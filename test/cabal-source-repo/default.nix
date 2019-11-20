{ stdenv, cabalProject', recurseIntoAttrs }:

with stdenv.lib;

let
  project = cabalProject' {
    name = "test-cabal-source-repo";
    index-state = "2019-04-30T00:00:00Z";
    src = ./.;
  };
  packages = project.hsPkgs;
in recurseIntoAttrs {
  inherit (project) plan-nix;
  run = stdenv.mkDerivation {
    name = "call-cabal-project-to-nix-test";

    buildCommand = ''
      exe="${packages.use-cabal-simple.components.exes.use-cabal-simple}/bin/use-cabal-simple${stdenv.hostPlatform.extensions.executable}"

      printf "checking whether executable runs... " >& 2
      cat ${packages.use-cabal-simple.components.exes.use-cabal-simple.run}

      touch $out
    '';

    meta.platforms = platforms.all;

    passthru = {
      # Attributes used for debugging with nix repl
      inherit pkgSet packages;
    };
  };
}