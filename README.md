# twterm

A full-featured TUI Twitter client

![screencast](http://twterm.ryota-ka.me/screencast.gif)

## Requirements

- Ruby (>= 2.4, compiled with ncurses and Readline)
- ncurses
- Readline
- [GNU Libidn](https://www.gnu.org/software/libidn/)

## Installation

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

```
$ nix-shell
```
