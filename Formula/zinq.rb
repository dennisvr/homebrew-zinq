# DO NOT EDIT BY HAND.
#
# The version, urls and sha256s below are rewritten on every release by the
# `release` workflow in the private source repo (dennisvr/galvanized), which
# builds the binaries, attaches the tarballs to a Release on this repo, and
# pushes the bump here. Two things that workflow's substitutions depend on:
#   - the version line stays `  version "..."` at two spaces of indent
#   - each sha256 stays 64 lowercase hex chars on the line right after its url
# The placeholder zeros below are a valid stand-in until the first release.
class Zinq < Formula
  desc "JSON and YAML processor compatible with jq"
  homepage "https://github.com/dennisvr/homebrew-zinq"
  version "0.0.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.0.1/zinq-0.0.1-arm64-apple-darwin.tar.gz"
      sha256 "92fd8878a20a974e9ba4b8446f97586c7383532bba61a48247af30f5bf8c8ca4"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.0.1/zinq-0.0.1-x86_64-apple-darwin.tar.gz"
      sha256 "64a85286847c946e7bbfa587bd3f83053adf55f751ce2ba31f96b075b1837d83"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.0.1/zinq-0.0.1-aarch64-linux.tar.gz"
      sha256 "90e9600e82c51b5b35910d2d1957e6986ff9f8085384d5ae3c3ec69d0f5c64df"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.0.1/zinq-0.0.1-x86_64-linux.tar.gz"
      sha256 "dc585bf0d0f8e68e07033fdda89c9165316bef6981be1979ffd25b2112221cdd"
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
