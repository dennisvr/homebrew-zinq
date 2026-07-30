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
  <img alt="Time to run each of 27 benchmarks, zinq against jq 1.8.2, grouped into queries, rewriting, reordering, path collection and streaming. zinq is faster on all 27, from 26 ms against 266 ms on .[0] to 0.411 s against 8.763 s on gsub." src="assets/speed-light.svg" width="880">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/memory-dark.svg">
  <img alt="Peak resident memory for the same 27 runs. zinq holds less on 20 of them; jq holds less when collecting every path at once and under --stream." src="assets/memory-light.svg" width="880">
</picture>

Together the 27 run in **4.1 s against jq's 20.8 s**, at a median peak of
**70 MB against 221 MB**. Two kinds of workload go the other way: collecting
every path of a document at once, and `--stream`. The `--stream` figure counts
the input file zinq maps into memory rather than what it allocates. Piped,
with no file to map, that same workload peaks at 2.8 MB against jq's 3.3.

<details>
<summary>Every measurement</summary>

| Benchmark | zinq | jq | zinq peak | jq peak |
|---|---:|---:|---:|---:|
| `.[0]` | 0.026 s | 0.266 s | 26 MB | 221 MB |
| `[.[] \| .tags \| length]` | 0.040 s | 0.293 s | 66 MB | 229 MB |
| `[.[] \| .name]` | 0.052 s | 0.365 s | 99 MB | 227 MB |
| `[.[] \| .score] \| sort \| .[-1]` | 0.081 s | 0.444 s | 98 MB | 232 MB |
| `.` (pretty-print) | 0.080 s | 0.888 s | 116 MB | 229 MB |
| `test("item-(?=0000)")` | 0.113 s | 0.577 s | 64 MB | 221 MB |
| `[.[] \| select(.active) \| {name, score}]` | 0.144 s | 0.503 s | 173 MB | 280 MB |
| `[.[] \| .tags[]] \| unique` | 0.144 s | 0.792 s | 145 MB | 253 MB |
| `test("^item-0000[0-9]3$")` | 0.182 s | 0.651 s | 64 MB | 221 MB |
| `gsub("[0-9]"; "#")` | 0.411 s | 8.763 s | 100 MB | 246 MB |
| `max_by(.score) \| .id` | 0.056 s | 0.341 s | 122 MB | 225 MB |
| `min_by(.score) \| .id` | 0.056 s | 0.335 s | 122 MB | 232 MB |
| `unique_by(.name) \| length` | 0.080 s | 0.377 s | 156 MB | 231 MB |
| `sort_by(.name) \| last` | 0.078 s | 0.373 s | 156 MB | 231 MB |
| `group_by(.name) \| length` | 0.100 s | 0.393 s | 214 MB | 283 MB |
| `sort_by(.id) \| last` | 0.142 s | 0.364 s | 156 MB | 231 MB |
| `[paths] \| length` ¹ | 0.028 s | 0.120 s | 68 MB | 48 MB |
| `reduce (inputs\|paths) as $p (0;.+1)` ¹ | 0.031 s | 0.130 s | 12 MB | 24 MB |
| `[path(..)] \| length` ¹ | 0.033 s | 0.090 s | 70 MB | 49 MB |
| `[tostream] \| length` ¹ | 0.054 s | 0.293 s | 144 MB | 58 MB |
| `[paths(type=="number")]` ¹ | 0.060 s | 0.121 s | 68 MB | 32 MB |
| `--stream -n first(inputs)` | 0.002 s | 0.003 s | 1.9 MB | 2.4 MB |
| `paths` ¹ | 0.019 s | 0.176 s | 12 MB | 24 MB |
| `tostream` ¹ | 0.026 s | 0.394 s | 12 MB | 25 MB |
| `fromstream(inputs)` ¹ | 0.043 s | 0.352 s | 37 MB | 25 MB |
| `--stream .` | 0.994 s | 1.662 s | 20 MB | 3 MB |
| `--stream select(length==2)` | 1.026 s | 1.781 s | 20 MB | 4 MB |

¹ On a 1.8 MB / 20k-record corpus; everything else on 18 MB / 200k records.

</details>

### YAML

The same filters read YAML directly, with no conversion step in front of them.
Same corpus, rendered as 20 MB of block-style YAML.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/yaml-speed-dark.svg">
  <img alt="Time to run four YAML workloads, zinq against yq (Go) 4.53.3, over 20 MB of block-style YAML. zinq is faster on all four: 0.149 s against 42.775 s projecting a field, 0.129 against 1.212 parse-bound, 0.140 against 1.225 on an edit, and 0.297 against 4.107 rendering YAML back out." src="assets/yaml-speed-light.svg" width="880">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/yaml-memory-dark.svg">
  <img alt="Peak resident memory for the same four YAML runs. zinq holds less on all four: 180 MB against yq's 2608 projecting a field, 143 against 1482 parse-bound, 151 against 1480 on an edit, and 158 against 5888 rendering YAML back out." src="assets/yaml-memory-light.svg" width="880">
</picture>

The first workload overstates the speed gap. yq is slow at collecting results
into an array specifically: asked for the same field as a stream it takes 2.3 s
rather than 43. The other three are the fairer comparison.

Memory is the wider gap, and it does not depend on that quirk: yq holds
**1.5 GB to read one field of the first record** of a 20 MB file, and 5.9 GB to
round-trip the document unchanged. zinq stays in a 143–180 MB band across all
four — the document is built once and the filter runs over it, so what the
filter does barely moves the footprint.

Measured 2026-07-30 against jq 1.8.2 and yq (Go) 4.53.3.

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

Output matches jq byte for byte wherever zinq answers. Where it doesn't, most
of it is unfinished rather than intended.

**Not there yet.**

- **YAML edits do not preserve comments or layout.** Results are re-emitted as
  clean block style. Round-tripping needs a lossless syntax tree, which is a
  bigger change than it looks; use yq meanwhile.
- **Arithmetic is IEEE doubles, not decimal.** A number's literal text survives
  unchanged, so an integer too wide for a double round-trips; but anything
  COMPUTED from it is a double, where jq 1.8 carries decNumber. `have_decnum`
  reports false for that reason.
- **No runtime guard on absurdly deep values.** Input nesting is capped exactly
  where jq caps it, but a value a filter builds past 10000 levels deep is
  serialized in full where jq writes `<skipped: too deep>`, and compared rather
  than refused.
- **Parse errors say what is wrong, not what a parser generator expected.** The
  file, line and caret are jq's; the sentence after them is zinq's own where
  jq's quotes bison's state machine.

**Deliberate.**

- **`~/.jq` is not read.** jq loads it as a personal function library. zinq will
  not run filter definitions written for another implementation; use `-L` for
  your own.

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
