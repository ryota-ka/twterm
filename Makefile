all:

docs:
	nix-shell --run 'bundle exec yard'

Gemfile.lock: Gemfile twterm.gemspec
	nix-shell --run 'bundle lock'

gemset.nix: Gemfile Gemfile.lock twterm.gemspec
	nix-shell -p bundix --run 'bundix --lock'

nix/Gemfile.lock: nix/Gemfile
	nix-shell -p bundix --run 'bundix --lock --gemfile=nix/Gemfile'

nix/gemset.nix: nix/Gemfile.lock
	nix-shell -p bundix --run 'bundix --gemfile=nix/Gemfile --gemset=nix/gemset.nix --lockfile=nix/Gemfile.lock'

postrelease: nix/Gemfile.lock nix/gemset.nix
