# twterm

A full-featured TUI Twitter client

![screencast](http://twterm.ryota-ka.me/screencast.gif)

## Installation

### With [Nix](https://nixos.org/) (Recommended)

```
$ nix-env --install --file https://github.com/ryota-ka/twterm/archive/v2.9.0.tar.gz
```

:warning: **Warning**

If you have `BUNDLE_PATH` configured in `~/.bundle/config`, `twterm` may fail due to `Bundler::GemNotFound`.

See [NixOS/nixpkgs#85989](https://github.com/NixOS/nixpkgs/issues/85989) for details.

### With [RubyGems](https://rubygems.org/)

####  Requirements

- Ruby (>= 2.5, < 3, compiled with ncurses and Readline)
- ncurses
- Readline
- [GNU Libidn](https://www.gnu.org/software/libidn/)

```
$ gem install twterm
```

## Usage

To launch twterm, just type in your console:

```
$ twterm
```

### Default key assignments

Key assignments can be configured by editing `~/.twterm/keys.toml`

key | operation
--- | ---
`h` `←` | previous tab
`j` `↓` | move down
`k` `↑` | move up
`l` `→` | next tab
`^N` | new tweet
`^T` | new tab
`w` | close current tab
`F10` `^C` | quit
`F1` | key assignments cheatsheet

## License

See the LICENSE file for license rights and limitations (MIT).

## Links

- http://twterm.ryota-ka.me/
- https://rubygems.org/gems/twterm

## Development

### Requirements

- [Nix](https://nixos.org/)

### Setting up development environment

```sh
$ nix-shell
```

Ruby version can be switched with `--arg` option (defaults to 2.7).

```sh
$ nix-shell --arg ruby 2.6
```
