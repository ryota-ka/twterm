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

### Basic key assignments

key | operation
--- | ---
`F` | add to favorite
`d` `C-d` | scroll down
`h` `C-b` `←` | show previous tab
`j` `C-n` `↓` | move down
`k` `C-p` `↑` | move up
`l` `C-f` `→` | show next tab
`n` | compose new tweet
`N` | open new tab
`r` | reply
`R` | retweet
`w` | close current tab
`Q` | quit
`?` | open key assignments cheatsheet

Type `?` key to see the full list of key assignments.

## License

See the LICENSE file for license rights and limitations (MIT).

## Links

- http://twterm.ryota-ka.me/
- https://rubygems.org/gems/twterm
