# homebrew-zinq

`zinq` is a jq-compatible JSON and YAML processor.

Existing jq scripts should just work: same filters, same flags, same output,
same exit codes. Every jq 1.8.2 builtin is there except `input_line_number`,
and the output is checked against real jq by differential tests and by jq's
own test suite.

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
  <img alt="Time to run each of 27 benchmarks, zinq against jq 1.8.2, grouped into queries, rewriting, reordering, path collection and streaming. zinq is faster on every one, from 27 ms against 264 ms on .[0] to 0.441 s against 8.646 s on gsub." src="assets/speed-light.svg" width="880">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/memory-dark.svg">
  <img alt="Peak resident memory for the same 27 runs. zinq holds less on 20 of them; jq holds less when collecting every path at once and under --stream." src="assets/memory-light.svg" width="880">
</picture>

Together the 27 run in **4.4 s against jq's 21.0 s**, at a median peak of
**116 MB against 234 MB**. Two kinds of workload go the other way: collecting
every path of a document at once, and `--stream`. The `--stream` figure counts
the input file zinq maps into memory rather than what it allocates. Piped,
with no file to map, that same workload peaks at 2.6 MB against jq's 3.5.

<details>
<summary>Every measurement</summary>

| Benchmark | zinq | jq | zinq peak | jq peak |
|---|---:|---:|---:|---:|
| `.[0]` | 0.027 s | 0.264 s | 25 MB | 220 MB |
| `[.[] \| .tags \| length]` | 0.043 s | 0.315 s | 66 MB | 232 MB |
| `[.[] \| .name]` | 0.054 s | 0.373 s | 102 MB | 230 MB |
| `[.[] \| .score] \| sort \| .[-1]` | 0.084 s | 0.452 s | 125 MB | 234 MB |
| `.` (pretty-print) | 0.087 s | 0.931 s | 116 MB | 235 MB |
| `test("item-(?=0000)")` | 0.116 s | 0.570 s | 64 MB | 222 MB |
| `[.[] \| select(.active) \| {name, score}]` | 0.142 s | 0.511 s | 199 MB | 283 MB |
| `[.[] \| .tags[]] \| unique` | 0.158 s | 0.848 s | 156 MB | 259 MB |
| `test("^item-0000[0-9]3$")` | 0.194 s | 0.646 s | 64 MB | 221 MB |
| `gsub("[0-9]"; "#")` | 0.441 s | 8.646 s | 99 MB | 251 MB |
| `max_by(.score) \| .id` | 0.058 s | 0.342 s | 126 MB | 238 MB |
| `min_by(.score) \| .id` | 0.059 s | 0.340 s | 138 MB | 238 MB |
| `sort_by(.name) \| last` | 0.085 s | 0.385 s | 159 MB | 258 MB |
| `unique_by(.name) \| length` | 0.085 s | 0.378 s | 159 MB | 256 MB |
| `group_by(.name) \| length` | 0.103 s | 0.393 s | 230 MB | 315 MB |
| `sort_by(.id) \| last` | 0.149 s | 0.366 s | 183 MB | 257 MB |
| `[paths] \| length` ¹ | 0.029 s | 0.120 s | 71 MB | 50 MB |
| `reduce (inputs\|paths) as $p (0;.+1)` ¹ | 0.034 s | 0.134 s | 12 MB | 25 MB |
| `[path(..)] \| length` ¹ | 0.035 s | 0.091 s | 72 MB | 50 MB |
| `[tostream] \| length` ¹ | 0.059 s | 0.298 s | 146 MB | 63 MB |
| `[paths(type=="number")]` ¹ | 0.066 s | 0.125 s | 71 MB | 33 MB |
| `--stream -n first(inputs)` | 0.003 s | 0.003 s | 1.8 MB | 2.4 MB |
| `paths` ¹ | 0.019 s | 0.176 s | 12 MB | 25 MB |
| `tostream` ¹ | 0.027 s | 0.398 s | 13 MB | 26 MB |
| `fromstream(inputs)` ¹ | 0.045 s | 0.349 s | 37 MB | 27 MB |
| `--stream .` | 1.080 s | 1.704 s | 20 MB | 4 MB |
| `--stream select(length==2)` | 1.103 s | 1.795 s | 20 MB | 4 MB |

¹ On a 1.8 MB / 20k-record corpus; everything else on 18 MB / 200k records.

</details>

### YAML

The same filters read YAML directly, with no conversion step in front of them.
Same corpus, rendered as 20 MB of block-style YAML.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/yaml-speed-dark.svg">
  <img alt="Time to run four YAML workloads, zinq against yq (Go) 4.53.3, over 20 MB of block-style YAML. zinq is faster on all four: 0.236 s against 45.315 s projecting a field, 0.205 against 1.179 parse-bound, 0.216 against 1.198 on an edit, and 0.407 against 4.092 rendering YAML back out." src="assets/yaml-speed-light.svg" width="880">
</picture>

The first workload overstates the gap. yq is slow at collecting results into an
array specifically: asked for the same field as a stream it takes 2.3 s rather
than 45. The other three are the fairer comparison. Memory is not measured for
the YAML runs.

Measured 2026-07-28 against jq 1.8.2 and yq (Go) 4.53.3.

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

- **YAML merge keys are not merged.** `<<: *anchor` is read as an ordinary key,
  so on a GitLab CI or Compose file `.job.image` comes back `null` rather than
  the inherited value — quietly, not as an error. Anchors and aliases on their
  own (`*ref`) resolve normally.
- **YAML edits do not preserve comments or layout.** Results are re-emitted as
  clean block style. Round-tripping needs a lossless syntax tree, which is a
  bigger change than it looks; use yq meanwhile.
- **`@base64d` does not validate its input.** jq rejects a string that isn't
  valid base64; zinq decodes what it can and hands back the bytes, so a
  truncated or already-decoded field passes through instead of erroring.
- `input_line_number` is the one jq 1.8.2 builtin not implemented, and `--seq`
  and `--stream-errors` the two flags not accepted.
- Strings cannot contain NUL bytes.

**Deliberate.**

- **`~/.jq` is not read.** jq loads it as a personal function library. zinq will
  not run filter definitions written for another implementation; use `-L` for
  your own.
- `1.` is an error where jq reads it as `1`. zinq echoes a number's source text
  back instead of reformatting it, and `1.` is not valid JSON to emit.

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
