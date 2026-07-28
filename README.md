# homebrew-zinq

`zinq` is a jq-compatible JSON and YAML processor.

## Performance

An 18 MB / 200k-record document, best of five interleaved rounds on an Apple
M3 Max, against jq 1.8.2. Every workload's output is compared to jq's byte for
byte before it is timed — a faster number means nothing if the bytes differ.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/speed-dark.svg">
  <img alt="Time to run each query, zinq against jq 1.8.2. zinq is faster on every workload, from 0.027 s against 0.264 s on .[0] to 0.441 s against 8.646 s on gsub." src="assets/speed-light.svg" width="880">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/memory-dark.svg">
  <img alt="Peak resident memory for the same runs. zinq holds less on every workload, from 25 MB against 220 MB on .[0] to 199 MB against 283 MB on select-and-construct." src="assets/memory-light.svg" width="880">
</picture>

Across the full suite of 27 workloads — which also covers `sort_by`/`group_by`,
path collection and `--stream` — zinq runs them in **4.4 s against jq's 21.0 s**,
at a median peak of **116 MB against 234 MB**. Two places jq holds less memory:
collecting every path of a document at once, and `--stream`, where zinq's figure
is the input mapping rather than its heap (piped, the same workload peaks at
2.6 MB against jq's 3.5).

| Workload | zinq | jq | zinq peak | jq peak |
|---|---:|---:|---:|---:|
| `.[0]` | 0.027 s | 0.264 s | 25 MB | 220 MB |
| `[.[] \| .tags \| length]` | 0.043 s | 0.315 s | 66 MB | 232 MB |
| `[.[] \| .name]` | 0.054 s | 0.373 s | 102 MB | 230 MB |
| `[.[] \| .score] \| sort \| .[-1]` | 0.084 s | 0.452 s | 125 MB | 234 MB |
| `.` (pretty-print) | 0.087 s | 0.931 s | 116 MB | 235 MB |
| `test("item-(?=0000)")` | 0.116 s | 0.570 s | 64 MB | 222 MB |
| `[.[] \| select(.active)]` | 0.142 s | 0.511 s | 199 MB | 283 MB |
| `[.[] \| .tags[]] \| unique` | 0.158 s | 0.848 s | 156 MB | 259 MB |
| `test("^item-0000[0-9]3$")` | 0.194 s | 0.646 s | 64 MB | 221 MB |
| `gsub("[0-9]"; "#")` | 0.441 s | 8.646 s | 99 MB | 251 MB |

Measured 2026-07-28.

## Install

```sh
brew tap dennisvr/zinq
brew trust dennisvr/zinq
brew install zinq
```

The `brew trust` step is required. Homebrew 6 refuses to load formulae from
third-party taps until they are trusted explicitly, so without it `brew install`
fails with `Refusing to load formula dennisvr/zinq/zinq from untrusted tap`.
Trusting the tap covers its current and future formulae; if you would rather
grant the narrowest possible permission, use
`brew trust --formula dennisvr/zinq/zinq` instead and repeat it after each
upgrade.

Once the tap is trusted, the one-line form works too:

```sh
brew install dennisvr/zinq/zinq
```

## Upgrade & uninstall

```sh
brew upgrade zinq
brew uninstall zinq
```

## Releases

Binaries are prebuilt and attached to this repo's [GitHub Releases](https://github.com/dennisvr/homebrew-zinq/releases). Each release ships one executable per platform — macOS Apple Silicon/Intel and Linux x86_64/ARM64 — with oniguruma statically linked, so there is no separate regex library to install. The macOS builds are self-contained. The Linux builds link glibc dynamically and are produced on Ubuntu 24.04, so they need glibc 2.39 or newer. The `zinq` source is not part of this repository.

Releases are published here automatically: CI in the private source repo builds the per-platform binaries, creates the Release on this repo with the tarballs attached, and commits the matching bump to `Formula/zinq.rb`. The formula is therefore generated — don't edit it by hand.
