<div align="center">
<br />
  <p>
    <img src="https://i.imgur.com/eS2ugrZ.png"/>
  </p>
  <br />
  <p>
    <a href="https://ko-fi.com/GeopJr" title="Donate to this project using Ko-Fi"><img src="https://img.shields.io/badge/Buy%20me%20a-KoFi-white.svg" alt="Ko-Fi donate button" /></a>
    <a href="https://liberapay.com/GeopJr"><img src="https://img.shields.io/liberapay/patrons/GeopJr.svg?logo=liberapay" alt="liberapay" ></a>
    <a href="https://github.com/GeopJr/Crycord/blob/master/LICENSE"><img src="https://img.shields.io/badge/LICENSE-MIT-000000.svg" alt="MIT" /></a>
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
$ ./crycord -h

<== [Crycord] ==>
    -v, --version                    Show version
    -h, --help                       Show help
    -gs, --groups                    Lists all available plugin groups
    -p, --plugins                    Lists all available plugins
    -c CSS_PATH, --css=CSS_PATH      Sets CSS location
    -f CORE_ASAR_PATH, --force=CORE_ASAR_PATH
                                     Forces an asar path
    -g PLUGIN_GROUP, --group=PLUGIN_GROUP
                                     Selects the plugin group(s) to install. Split multiple groups with commas(,).
```

```
$ ./crycord -c ./Downloads/css.css

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

## Benchmarks

Crycord:
```
$ time ./crycord -c ~/Downloads/css.css
...

real	0m2,942s
user	0m2,932s
sys	0m0,462s
```

BeautifulDiscord:
```
$ time python3 -m beautifuldiscord --css ~/Downloads/css.css
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

## Goals

As I also wrote the shard that manages the asar pack/extract (these 2 functions at least),
my main goal is to achieve max speed and max compatibility. Using Crystal only tools like Path, File, Dir etc.
is one way to reach it. However, since I don't have access to a Mac and Windows doesn't have proper support, some
paths (Discord config) are made specifically for linux.

## How is it different to BeautifulDiscord?

First of all, it's written, well... in Crystal!

That alone makes it a lot faster!

Crycord also has a plugin(?) system!

Lastly, it can patch the flatpak version.

## TODO

- Use a cross-platform way to find Discord's pid
- Clean the module collector
- GitHub action using docker in an attempt to build static builds automatically

## Contributing

1. Fork it (<https://github.com/your-github-user/crycord/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [GeopJr](https://github.com/GeopJr) - creator and maintainer
- [leovoel](https://github.com/leovoel) - CSS injector
- [Rapptz](https://github.com/Rapptz) - BeautifulDiscord Maintainer
