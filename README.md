# twterm

A full-featured TUI Twitter client

## Screenshot

![screenshot](http://twterm.ryota-ka.me/screenshot.png)

## Requirements

- Ruby (>= 2.1, compiled with ncurses and Readline)
- ncurses
- Readline

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
