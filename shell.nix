{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  gems = bundlerEnv {
    inherit ruby;
    pname = "twterm";
    gemdir = ./.;
  };
in
mkShell rec {
  buildInputs = [
    bundix
    bundler
    gems
    libidn
    ncurses
    readline
    ruby
  ];
  shellHook = ''
    alias twterm='bundle exec bin/twterm'

    bundle install -j=4 --path=vendor/bundle

    ruby --version
    bundle --version
  '';
}
