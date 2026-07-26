# DO NOT EDIT BY HAND.
#
# The version, urls and sha256s below are rewritten on every release by the
# `release` workflow in the private source repo (dennisvr/galvanized), which
# builds the binaries, attaches the tarballs to a Release on this repo, and
# pushes the bump here. Two things that workflow's substitutions depend on:
#   - the version line stays `  version "..."` at two spaces of indent
#   - each sha256 stays 64 lowercase hex chars on the line right after its url
class Zinq < Formula
  desc "JSON and YAML processor compatible with jq"
  homepage "https://github.com/dennisvr/homebrew-zinq"
  version "0.1.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.1.0/zinq-0.1.0-arm64-apple-darwin.tar.gz"
      sha256 "c6872f2c867bf9b74680135a95e2fe9e15898c0d5efb2e9af98de1abce792e97"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.1.0/zinq-0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "6ed5c311a35bd55ee595703d35218b132a8cd3cc4a9a4975783ed4da17c3d689"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.1.0/zinq-0.1.0-aarch64-linux.tar.gz"
      sha256 "6b2846208e89c4083d28200c0598a895ccdbe3ce79d470811a218d7b7f7741ae"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.1.0/zinq-0.1.0-x86_64-linux.tar.gz"
      sha256 "3f3e3ba8416bb6b732d2850b0c731b6d05e89b72fbf2ff2bb63731ea2af5ec60"
    end
  end

  def install
    bin.install "zinq"
  end

  test do
    assert_equal "1", pipe_output("#{bin}/zinq -c '.a'", '{"a":1}').chomp
    assert_equal '{"n":"x"}', pipe_output("#{bin}/zinq -c '{n: .name}'", '{"name":"x"}').chomp
    assert_equal "true", pipe_output(%Q(#{bin}/zinq -nc '"abc" | test("b")')).chomp
  end
end
