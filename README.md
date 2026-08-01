# homebrew-zinq

`zinq` is a jq-compatible JSON and YAML processor.

Existing jq scripts should just work: same filters, same flags, same output,
same exit codes. Every jq 1.8.2 builtin is implemented, and the output is
checked against real jq by differential tests and by jq's own test suite.

It doesn't inherit your jq setup, though. `~/.jq` isn't read, and a few other
things differ; they're listed under [Gaps and differences](#gaps-and-differences).

> **zinq is beta.** It's pre-1.0 and hasn't seen much production use yet. Check
> its output before you put it somewhere that matters, and keep jq around.
> Provided as is, without warranty of any kind — use at your own risk.

## Performance

Every JSON benchmark is compared to jq's output byte for byte before it is
timed — a faster number means nothing if the bytes differ.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/speed-dark.svg">
  <img alt="Time to run each of 27 benchmarks, zinq against jq 1.8.2, grouped into queries, rewriting, reordering, path collection and streaming. zinq is faster on all 27, from 26 ms against 265 ms on .[0] to 0.386 s against 8.502 s on gsub." src="assets/speed-light.svg" width="880">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/memory-dark.svg">
  <img alt="Peak resident memory for the same 27 runs. zinq holds less on 23 of them; jq holds less on two of the path-collection rows and on --stream's whole-document walks." src="assets/memory-light.svg" width="880">
</picture>

Together the 27 run in **4.0 s against jq's 20.6 s**, at a median peak of
**66 MB against 220 MB**. Two kinds of workload go the other way: two of the
collect-every-path rows, and `--stream`. The `--stream` figure counts
the input file zinq maps into memory rather than what it allocates. Piped,
with no file to map, that same workload peaks at 2.8 MB against jq's 3.3.

<details>
<summary>Every measurement</summary>

| Benchmark | zinq | jq | zinq peak | jq peak |
|---|---:|---:|---:|---:|
| `.[0]` | 0.026 s | 0.265 s | 26 MB | 218 MB |
| `[.[] \| .tags \| length]` | 0.043 s | 0.311 s | 66 MB | 228 MB |
| `[.[] \| .name]` | 0.047 s | 0.367 s | 80 MB | 228 MB |
| `[.[] \| .score] \| sort \| .[-1]` | 0.067 s | 0.447 s | 80 MB | 226 MB |
| `.` (pretty-print) | 0.084 s | 0.913 s | 116 MB | 229 MB |
| `test("item-(?=0000)")` | 0.114 s | 0.584 s | 64 MB | 220 MB |
| `[.[] \| select(.active) \| {name, score}]` | 0.142 s | 0.505 s | 141 MB | 279 MB |
| `[.[] \| .tags[]] \| unique` | 0.125 s | 0.782 s | 98 MB | 264 MB |
| `test("^item-0000[0-9]3$")` | 0.180 s | 0.632 s | 64 MB | 215 MB |
| `gsub("[0-9]"; "#")` | 0.386 s | 8.502 s | 81 MB | 240 MB |
| `max_by(.score) \| .id` | 0.051 s | 0.347 s | 92 MB | 232 MB |
| `min_by(.score) \| .id` | 0.051 s | 0.348 s | 92 MB | 236 MB |
| `unique_by(.name) \| length` | 0.078 s | 0.385 s | 113 MB | 252 MB |
| `sort_by(.name) \| last` | 0.076 s | 0.379 s | 111 MB | 251 MB |
| `group_by(.name) \| length` | 0.092 s | 0.386 s | 152 MB | 283 MB |
| `sort_by(.id) \| last` | 0.063 s | 0.371 s | 114 MB | 248 MB |
| `[paths] \| length` ¹ | 0.025 s | 0.122 s | 41 MB | 50 MB |
| `reduce (inputs\|paths) as $p (0;.+1)` ¹ | 0.033 s | 0.132 s | 12 MB | 24 MB |
| `[path(..)] \| length` ¹ | 0.025 s | 0.087 s | 43 MB | 48 MB |
| `[tostream] \| length` ¹ | 0.044 s | 0.284 s | 86 MB | 62 MB |
| `[paths(type=="number")]` ¹ | 0.056 s | 0.118 s | 42 MB | 32 MB |
| `--stream -n first(inputs)` | 0.002 s | 0.003 s | 1.9 MB | 2.4 MB |
| `paths` ¹ | 0.023 s | 0.175 s | 12 MB | 24 MB |
| `tostream` ¹ | 0.030 s | 0.394 s | 12 MB | 26 MB |
| `fromstream(inputs)` ¹ | 0.045 s | 0.350 s | 23 MB | 27 MB |
| `--stream .` | 1.019 s | 1.664 s | 20 MB | 4 MB |
| `--stream select(length==2)` | 1.054 s | 1.786 s | 20 MB | 4 MB |

¹ On a 1.8 MB / 20k-record corpus; everything else on 18 MB / 200k records.

</details>

### YAML

The same filters read YAML directly, with no conversion step in front of them.
Same corpus, rendered as 20 MB of block-style YAML.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/yaml-speed-dark.svg">
  <img alt="Time to run four YAML workloads, zinq against yq (Go) 4.53.3, over 20 MB of block-style YAML. zinq is faster on all four: 0.140 s against 41.904 s projecting a field, 0.121 against 1.157 parse-bound, 0.129 against 1.155 on an edit, and 0.294 against 3.782 rendering YAML back out." src="assets/yaml-speed-light.svg" width="880">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/yaml-memory-dark.svg">
  <img alt="Peak resident memory for the same four YAML runs. zinq holds less on all four: 162 MB against yq's 2674 projecting a field, 143 against 1483 parse-bound, 162 against 1479 on an edit, and 158 against 5981 rendering YAML back out." src="assets/yaml-memory-light.svg" width="880">
</picture>

The first workload overstates the speed gap. yq is slow at collecting results
into an array specifically: asked for the same field as a stream it takes 2.3 s
rather than 42. The other three are the fairer comparison.

Memory is the wider gap. yq holds **1.5 GB to read one field of the first
record** of a 20 MB file, and 6.0 GB to round-trip it unchanged. zinq stays
between 143 and 162 MB on all four.

Measured 2026-08-01 against jq 1.8.2 and yq (Go) 4.53.3.

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

## Usage

Same filters and flags as jq:

```sh
zinq '.[] | select(.active) | .name' users.json
zinq -r '.[].name' users.json
curl -s https://api.example.com/items | zinq -c '.[0]'
```

`.yaml` and `.yml` files are detected by suffix; `--yaml-input` and
`--yaml-output` force it either way:

```sh
zinq '.spec.replicas' deploy.yaml
zinq --yaml-output '.metadata.labels.env = "prod"' deploy.yaml
```

`zinq --help` lists every flag and the filters implemented so far.

## Gaps and differences

Output matches jq byte for byte, except the two number cases below.

**Not there yet.**

- **YAML edits lose comments and layout.** Output is clean block style; use yq
  if you need round-tripping.
- **YAML `.inf`, `-.inf` and `.nan` don't round-trip.** They read as
  `1.7976931348623157e+308`, its negation, and `null`. yq keeps them. JSON is
  unaffected.
- **`have_decnum` is false.** Literal text survives, so a wide integer
  round-trips, but arithmetic is doubles — as it is in jq. One real difference:
  `1E1234567890` prints as written, where jq saturates it.
- **Parse errors are worded differently.** Same file, line and caret; the
  sentence after them is zinq's, not bison's.

**Deliberate.**

- **`~/.jq` is not read; `~/.zinq` is.** A file is loaded as a library; a
  directory is added to the search path.
- **Three builtins jq 1.8.2 dropped still work:** `leaf_paths`, `pow10` and
  `toarray`.

The benchmarks above were run on one machine, an Apple M3 Max. Linux builds
ship but their numbers are not published.

## Upgrade & uninstall

```sh
brew upgrade zinq
brew uninstall zinq
```

## Releases

Binaries are prebuilt and attached to this repo's [GitHub Releases](https://github.com/dennisvr/homebrew-zinq/releases). Each release ships one executable per platform — macOS Apple Silicon/Intel and Linux x86_64/ARM64 — with oniguruma statically linked, so there is no separate regex library to install. The macOS builds are self-contained. The Linux builds link glibc dynamically and are produced on Ubuntu 24.04, so they need glibc 2.39 or newer.

The `zinq` source is not public yet. It's written in a language that is itself still under development; the plan is to open the source once that settles.

Releases are published here automatically: CI in the private source repo builds the per-platform binaries, creates the Release on this repo with the tarballs attached, and commits the matching bump to `Formula/zinq.rb`. The formula is therefore generated — don't edit it by hand.
