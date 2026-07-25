# homebrew-zinq

`zinq` is a jq-compatible JSON and YAML processor.

## Install

```sh
brew tap dennisvr/zinq
brew install zinq
```

Or in one line:

```sh
brew install dennisvr/zinq/zinq
```

## Upgrade & uninstall

```sh
brew upgrade zinq
brew uninstall zinq
```

## Releases

Binaries are prebuilt and attached to this repo's [GitHub Releases](https://github.com/dennisvr/homebrew-zinq/releases). Each release ships a self-contained, statically linked executable per platform (macOS Apple Silicon/Intel, Linux x86_64/ARM64) with no external dependencies. The `zinq` source is not part of this repository.

Releases are published here automatically: CI in the private source repo builds the per-platform binaries, creates the Release on this repo with the tarballs attached, and commits the matching bump to `Formula/zinq.rb`. The formula is therefore generated — don't edit it by hand.