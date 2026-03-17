{ stdenv, ... }:

stdenv.mkDerivation {
  pname = "textfoxy";
  version = "git";

  src = ../../.;

  installPhase = ''
    mkdir -p $out/chrome
    cp -r chrome/* $out/chrome
    cp user.js $out/user.js
  '';
}
