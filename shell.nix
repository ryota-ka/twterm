{ pkgs ? import <nixpkgs> { }, ruby ? 2.7 }:

with pkgs;
let
  mri =
    if ruby == 2.5
    then ruby_2_5
    else if ruby == 2.6
    then ruby_2_6
    else if ruby == 2.7
    then ruby_2_7
    else abort "Unsupported Ruby version";
  gems = bundlerEnv {
    pname = "twterm";
    gemdir = ./.;
    ruby = mri;
  };
in
mkShell rec {
  buildInputs = [
    bundix
    bundler
    gems
    libffi
    libidn
    mri
    ncurses
    readline
  ];
  shellHook = ''
    alias twterm='bundle exec bin/twterm'

    bundle install -j=4 --path=vendor/bundle

    ruby --version
    bundle --version
  '';
}
