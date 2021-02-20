# twterm

A full-featured TUI Twitter client

![screencast](http://twterm.ryota-ka.me/screencast.gif)

## Installation

<details>
<summary>Nix (Recommended)</summary>

All the required dependencies will automatically be installed together.

```sh
$ nix-env --install --file https://github.com/ryota-ka/twterm/archive/v2.9.0.tar.gz
```
:warning: **Caution**

If you have `BUNDLE_PATH` configured in `~/.bundle/config`, `twterm` may fail due to `Bundler::GemNotFound`.
See [NixOS/nixpkgs#85989](https://github.com/NixOS/nixpkgs/issues/85989) for details.

</details>

<details>
<summary>RubyGems</summary>

You also have to install the following dependencies manually.

- [Ruby](https://www.ruby-lang.org/) (>= 2.5, < 3, compiled with ncurses and Readline)
- [ncurses](https://invisible-island.net/ncurses/)
- [GNU Readline](https://tiswww.case.edu/php/chet/readline/rltop.html)
- [GNU Libidn](https://www.gnu.org/software/libidn/)

```sh
$ gem install twterm
```

</details>

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
