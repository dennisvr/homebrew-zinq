# homebrew-zinq

`zinq` is a fast, low-memory, jq-compatible JSON and YAML processor.

Existing jq scripts should just work: same filters, same flags, same output,
same exit codes — typically in a fifth of the time and less than half the memory.
Every jq 1.8.2 builtin is implemented, and the output is checked against real jq
by differential tests and by jq's own test suite.

Reads `~/.zinq`; copy your `~/.jq` over if you want to reuse it.
A few other things differ; they're listed under [Gaps and differences](#gaps-and-differences).

> **zinq is beta.** It's pre-1.0 and hasn't seen much production use yet. Check
> its output before you put it somewhere that matters, and keep jq around.
> Provided as is, without warranty of any kind — use at your own risk.

zinq is Apache-2.0. The source isn't public yet — see
[Releases](#releases) — but the licence applies to the binaries you install
today, not just to whatever gets published later.

## Performance

Every JSON benchmark is compared to jq's output byte for byte before it is
timed — a faster number means nothing if the bytes differ.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/speed-dark.svg">
  <img alt="Time to run each of 27 benchmarks, zinq against jq 1.8.2, grouped into queries, rewriting, reordering, path collection and streaming. zinq is faster on all 27, from 25 ms against 254 ms on .[0] to 0.382 s against 8.277 s on gsub." src="assets/speed-light.svg" width="880">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/memory-dark.svg">
  <img alt="Peak resident memory for the same 27 runs. zinq holds less on 23 of them; jq holds less on two of the path-collection rows and on --stream's whole-document walks, where zinq's number is mostly the input file it maps." src="assets/memory-light.svg" width="880">
</picture>

Together the 27 run in **2.7 s against jq's 20.1 s**, at a median peak of
**91 MB against 239 MB**. On time nothing goes the other way any more —
`--stream`, once the narrowest row, runs 4.5x ahead since zinq's output
buffering landed. On memory, four rows are still jq's: two of the
collect-every-path rows, and `--stream`'s whole-document walks, where
zinq's figure is mostly the input file it maps.

<details>
<summary>Every measurement</summary>

| Benchmark | zinq | jq | zinq peak | jq peak |
|---|---:|---:|---:|---:|
| `.[0]` | 0.025 s | 0.254 s | 27 MB | 238 MB |
| `[.[] \| .tags \| length]` | 0.043 s | 0.296 s | 92 MB | 243 MB |
| `[.[] \| .name]` | 0.046 s | 0.345 s | 106 MB | 241 MB |
| `[.[] \| .score] \| sort \| .[-1]` | 0.065 s | 0.414 s | 106 MB | 244 MB |
| `.` (pretty-print) | 0.087 s | 0.919 s | 131 MB | 250 MB |
| `test("item-(?=0000)")` | 0.108 s | 0.559 s | 91 MB | 238 MB |
| `[.[] \| select(.active) \| {name, score}]` | 0.125 s | 0.468 s | 166 MB | 296 MB |
| `[.[] \| .tags[]] \| unique` | 0.130 s | 0.821 s | 124 MB | 273 MB |
| `test("^item-0000[0-9]3$")` | 0.166 s | 0.625 s | 91 MB | 239 MB |
| `gsub("[0-9]"; "#")` | 0.382 s | 8.277 s | 107 MB | 254 MB |
| `max_by(.score) \| .id` | 0.050 s | 0.331 s | 101 MB | 247 MB |
| `min_by(.score) \| .id` | 0.050 s | 0.327 s | 101 MB | 248 MB |
| `unique_by(.name) \| length` | 0.075 s | 0.374 s | 120 MB | 255 MB |
| `sort_by(.name) \| last` | 0.072 s | 0.366 s | 120 MB | 257 MB |
| `group_by(.name) \| length` | 0.086 s | 0.380 s | 161 MB | 317 MB |
| `sort_by(.id) \| last` | 0.058 s | 0.358 s | 122 MB | 256 MB |
| `[paths] \| length` ¹ | 0.025 s | 0.122 s | 42 MB | 54 MB |
| `reduce (inputs\|paths) as $p (0;.+1)` ¹ | 0.031 s | 0.132 s | 10 MB | 26 MB |
| `[path(..)] \| length` ¹ | 0.025 s | 0.090 s | 44 MB | 54 MB |
| `[tostream] \| length` ¹ | 0.043 s | 0.279 s | 87 MB | 66 MB |
| `[paths(type=="number")]` ¹ | 0.058 s | 0.123 s | 42 MB | 35 MB |
| `--stream -n first(inputs)` | 0.003 s | 0.004 s | 2.3 MB ² | 2.7 MB |
| `paths` ¹ | 0.020 s | 0.174 s | 11 MB | 26 MB |
| `tostream` ¹ | 0.026 s | 0.373 s | 11 MB | 27 MB |
| `fromstream(inputs)` ¹ | 0.042 s | 0.337 s | 24 MB | 27 MB |
| `--stream .` | 0.364 s | 1.622 s | 22 MB ² | 3 MB |
| `--stream select(length==2)` | 0.499 s | 1.736 s | 22 MB ² | 3 MB |

¹ On a 1.8 MB / 20k-record corpus; everything else on 18 MB / 200k records.

² Counts the input file zinq maps into memory (plus a 1 MB output buffer),
not a working set. Piped, with no file to map, `--stream .` runs 0.51 s at
4.9 MB against jq's 1.7 s at 3.0 — and `--unbuffered`, honored with jq's
meaning, keeps the old 2.9 MB footprint.

</details>

### YAML

The same filters read YAML directly, with no conversion step in front of them.
Same corpus, rendered as 20 MB of block-style YAML.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/yaml-speed-dark.svg">
  <img alt="Time to run four YAML workloads, zinq against yq (Go) 4.53.3, over 20 MB of block-style YAML. zinq is faster on all four: 0.130 s against 38.161 s projecting a field, 0.110 against 1.113 parse-bound, 0.117 against 1.114 on an edit, and 0.280 against 3.637 rendering YAML back out." src="assets/yaml-speed-light.svg" width="880">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/yaml-memory-dark.svg">
  <img alt="Peak resident memory for the same four YAML runs. zinq holds less on all four: 193 MB against yq's 2967 projecting a field, 147 against 1485 parse-bound, 163 against 1483 on an edit, and 183 against 5348 rendering YAML back out." src="assets/yaml-memory-light.svg" width="880">
</picture>

| Workload | zinq | yq | zinq peak | yq peak |
|---|---:|---:|---:|---:|
| Project a field into an array | 0.130 s | 38.161 s | 193 MB | 2967 MB |
| Parse-bound (read one field of the first record) | 0.110 s | 1.113 s | 147 MB | 1485 MB |
| Edit a value in place | 0.117 s | 1.114 s | 163 MB | 1483 MB |
| Round-trip YAML back out | 0.280 s | 3.637 s | 183 MB | 5348 MB |

The first row overstates the speed gap. yq is slow at collecting results into
an array specifically: asked for the same field as a stream it takes 2.3 s
rather than 42. The other three are the fairer comparison.

Memory is the wider gap, and it holds across all four. yq needs 1.5 GB to read
one field of the first record of a 20 MB file, and 5.3 GB to round-trip it
unchanged. zinq stays between 147 and 193 MB.

JSON and YAML measured 2026-08-04 against jq 1.8.2 and yq (Go) 4.53.3, on
one machine — an Apple M3 Max, macOS 26 — so absolute figures are that
machine's; the ratios are the claim. Linux builds ship but their numbers
are not published.

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

Output matches jq byte for byte except where noted here.

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

- **`~/.zinq` replaces `~/.jq`.** A file is loaded as a library; a directory is
  added to the search path.
- **Three builtins jq 1.8.2 dropped still work:** `leaf_paths`, `pow10` and
  `toarray`.

## Releases

Binaries are prebuilt and attached to this repo's
[GitHub Releases](https://github.com/dennisvr/homebrew-zinq/releases). Each
release ships one executable per platform — macOS Apple Silicon/Intel and Linux
x86_64/ARM64 — with oniguruma statically linked, so there is no separate regex
library to install. The macOS builds are self-contained. The Linux builds link
glibc dynamically and are produced on Ubuntu 24.04, so they need glibc 2.39 or
newer.

The `zinq` source is not public yet. It's written in a language that is itself
still under development; the plan is to open the source once that settles. The
binaries are Apache-2.0 in the meantime, and each tarball carries a copy of the
licence.

Releases are published here automatically: CI in the private source repo builds
the per-platform binaries, creates the Release on this repo with the tarballs
attached, and commits the matching bump to `Formula/zinq.rb`. The formula is
therefore generated — don't edit it by hand.

## Upgrade & uninstall

```sh
brew upgrade zinq
brew uninstall zinq
```

## Licence

Apache License 2.0. See [LICENSE](LICENSE).
