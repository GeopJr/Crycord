<div align="center">
<br />
  <p>
    <img src="https://i.imgur.com/eS2ugrZ.png"/>
  </p>
</div>

# crycord

Crycord is a modular Discord Client Mod written in Crystal.

Uses [asar-cr](https://github.com/GeopJr/asar-cr).

## Installation

You can download the *statically* linked build from the releases page!

## Building

1. `shards install`
2. `crystal build --release`

*Note:* Static builds can only be built in AlpineLinux

## Usage

```
$ crycord -h

Crycord v1.3.2
Usage:
    crycord [arguments]
    
Examples:
    crycord -c ./Downloads/style.css

Arguments:
    -v, --version                    Show version
    -h, --help                       Show help
    -l, --list                       Lists all available plugin groups & plugins
    -r, --revert                     Reverts back to original asar
    -p PLUGINS, --plugins=PLUGINS    Selects the plugin(s) to install. Split multiple groups with commas(,).
    -c CSS_PATH, --css=CSS_PATH      Sets CSS location
    -f CORE_ASAR_PATH, --force=CORE_ASAR_PATH
                                     Forces an asar path
    -g PLUGIN_GROUP, --group=PLUGIN_GROUP
                                     Selects the plugin group(s) to install. Split multiple groups with commas(,).
```

```
$ crycord -c ./Downloads/style.css

Flatpak Detected:
Make sure it has access to your CSS file
Usually ~/Downloads is accessible
Extracting core.asar...
Installing enable_css...
Installing enable_https...
Packing core.asar...
Done!
Restart Discord to see the results!
```

## GUI

There's a GTK GUI for Crycord on [Crycord-GUI](https://github.com/GeopJr/Crycord-GUI)

## Plugins
|         Name        | Group |         Description        | Maintainer |
| :-----------------: | :---: | :------------------------: | :--------: |
|     enable_https    |  core |        Disables CSP        |   GeopJr   |
|      enable_css     |  core |    Enables css injection   |   GeopJr   |
| unrestricted_resize | extra | Removes window size limits |   GeopJr   |
| enable_web_tools | extra | Enables web tools on Discord stable |   GeopJr   |

To enable groups of plugins use `$ crycord -g core,extra -c /path/to/css`

> Note: `core` is enabled by default so there's no need to include it.

## Benchmarks

Crycord:
```
$ time crycord -c ~/Downloads/style.css
...

real	0m2,942s
user	0m2,932s
sys	0m0,462s
```

BeautifulDiscord:
```
$ time python3 -m beautifuldiscord --css ~/Downloads/style.css
...

real	0m4,593s
user	0m2,026s
sys	0m2,381s
```

## (Laggy) Gifs

![install](https://i.imgur.com/gf6Sa8i.gif)
![restore](https://i.imgur.com/1ooO8me.gif)
![hotreload](https://i.imgur.com/e102GRD.gif)

## WARNING

- Any Discord Client modification is against their T.O.S.
- I am not responsible if your account gets terminated.
- Using a client mod such as this (and all others), deactivates many electron security functions.
- If a Discord Staff happens to stumble upon this, I don't use this tool on my account and it's made for educational purposes.

## Sponsors

<div align="center">

[![GeopJr Sponsors](https://cdn.jsdelivr.net/gh/GeopJr/GeopJr@main/sponsors.svg)](https://github.com/sponsors/GeopJr)

</div>

## Contributing

1. Read the [Code of Conduct](https://github.com/GeopJr/Collision/blob/main/CODE_OF_CONDUCT.md)
2. Fork it (<https://github.com/GeopJr/crycord/fork>)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
