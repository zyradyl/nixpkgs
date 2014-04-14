{ pkgs, stdenv, nodejs, fetchurl, neededNatives, self, generated ? ./node-packages-generated.nix }:

{
  nativeDeps = {
    "node-expat"."*" = [ pkgs.expat ];
    "rbytes"."*" = [ pkgs.openssl ];
    "phantomjs"."~1.9" = [ pkgs.phantomjs_192 ];
  };

  buildNodePackage = import ../development/web/nodejs/build-node-package.nix {
    inherit stdenv nodejs neededNatives;
    inherit (pkgs) runCommand;
  };

  patchLatest = srcAttrs:
    let src = fetchurl srcAttrs; in pkgs.runCommand src.name {} ''
      mkdir unpack
      cd unpack
      unpackFile ${src}
      chmod -R +w */
      mv */ package 2>/dev/null || true
      sed -i -e "s/:\s*\"latest\"/:  \"*\"/" -e "s/:\s*\"\(https\?\|git\(\+\(ssh\|http\|https\)\)\?\):\/\/[^\"]*\"/: \"*\"/" package/package.json
      mv */ $out
    '';

  /* Put manual packages below here (ideally eventually managed by npm2nix */
} // import generated { inherit self fetchurl; inherit (pkgs) lib; }
