{ stdenv, lib, cabalProject', recurseIntoAttrs, haskellLib, testSrc, compiler-nix-name }:

with lib;

let
  project = cabalProject' {
    inherit compiler-nix-name;
    src = testSrc "project-flags";
  };
  packages = project.hsPkgs;

in recurseIntoAttrs {
  ifdInputs = {
    inherit (project) plan-nix;
  };
  run = stdenv.mkDerivation {
    name = "call-cabal-project-to-nix-test";

    buildCommand = ''
      exe="${packages.test-project-flags.components.exes.test-project-flags-exe.exePath}"

      printf "checking whether executable runs... " >& 2
      cat ${haskellLib.check packages.test-project-flags.components.exes.test-project-flags-exe}/test-stdout

      touch $out
    '';

    meta.platforms = platforms.all;

    passthru = {
      # Attributes used for debugging with nix repl
      inherit pkgSet packages;
      plan-nix = plan.nix;
    };
  };
}