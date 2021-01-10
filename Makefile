all:

docs:
	nix-shell --run 'bundle exec yard'

Gemfile.lock: Gemfile twterm.gemspec
	nix-shell --run 'bundle lock'

gemset.nix: Gemfile Gemfile.lock twterm.gemspec
	nix-shell -p bundix --run 'bundix --lock'

nix/Gemfile.lock: Gemfile.lock
	cp -f Gemfile.lock nix/Gemfile.lock

nix/gemset.nix: nix/Gemfile.lock
	nix-shell -p bundix --run 'bundix --gemfile=nix/Gemfile --gemset=nix/gemset.nix --lockfile=nix/Gemfile.lock'

prerelease: nix/Gemfile.lock nix/gemset.nix
