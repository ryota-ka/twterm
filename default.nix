{ pkgs ? import <nixpkgs> { } }:

with pkgs;

bundlerApp {
  inherit ruby;

  pname = "twterm";
  exes = [ "twterm" ];
  gemdir = ./nix;
  installManpages = false;

  buildInputs = [ libidn ncurses readline ];

  meta = with lib; {
    description = "A full-featured TUI Twitter client";
    homepage = "https://twterm.ryota-ka.me/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
