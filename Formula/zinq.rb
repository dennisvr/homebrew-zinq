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
  version "0.6.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.6.0/zinq-0.6.0-arm64-apple-darwin.tar.gz"
      sha256 "da135158bc02b2f35ec2a7409e328b1a610ed0ff7b9c26e466aae7fdc2acc621"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.6.0/zinq-0.6.0-x86_64-apple-darwin.tar.gz"
      sha256 "e89b59b1472cc340b5b85d59a087ff764282da3cb0f9cc7f04229416c40b0ee5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.6.0/zinq-0.6.0-aarch64-linux.tar.gz"
      sha256 "1874a4df8b1401baa09374d845569d7c3fa4f30f59fbad6ea69607f17b12fd55"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.6.0/zinq-0.6.0-x86_64-linux.tar.gz"
      sha256 "b17bf2f528e1c386e1b3b9aa89c48559449db41c0c54d978fc4e1a4a52d1d540"
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
