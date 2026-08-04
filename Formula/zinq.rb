# DO NOT EDIT BY HAND.
#
# The version, urls and sha256s below are rewritten on every release by the
# `release` workflow in the private source repo, which
# builds the binaries, attaches the tarballs to a Release on this repo, and
# pushes the bump here. Two things that workflow's substitutions depend on:
#   - the version line stays `  version "..."` at two spaces of indent
#   - each sha256 stays 64 lowercase hex chars on the line right after its url
class Zinq < Formula
  desc "JSON and YAML processor compatible with jq"
  homepage "https://github.com/dennisvr/homebrew-zinq"
  version "0.7.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.7.1/zinq-0.7.1-arm64-apple-darwin.tar.gz"
      sha256 "6b924c23e3ee82b625a46665656612e7dd543d47e57702733bbe170a8ced33b0"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.7.1/zinq-0.7.1-x86_64-apple-darwin.tar.gz"
      sha256 "59d952f08e904d2a155dc4b5b2e26060e38e5c90ff673f8f048cb3e232a6228a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.7.1/zinq-0.7.1-aarch64-linux.tar.gz"
      sha256 "ddff3ea1e4660f13de025cf09af0e6958ba3e4fc28e7f7afeac356bc96452f7d"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.7.1/zinq-0.7.1-x86_64-linux.tar.gz"
      sha256 "680ce4cf9fd40ee7dd682a5f7907b461554127705e470b457847c387b1213e56"
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
