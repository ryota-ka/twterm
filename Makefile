all:

gemset.nix: Gemfile Gemfile.lock twterm.gemspec
	nix-shell -p bundix --run 'bundix --lock'
