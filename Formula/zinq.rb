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
  version "0.7.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.7.0/zinq-0.7.0-arm64-apple-darwin.tar.gz"
      sha256 "4ea95f36f3415de6e35946d0aa23b2afcfbad5a6dd4b40bd3b2b936cf676cefd"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.7.0/zinq-0.7.0-x86_64-apple-darwin.tar.gz"
      sha256 "9928217689aebd387e90b496e05d84374349531dbd8a253768f228b6e4ba9ef7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.7.0/zinq-0.7.0-aarch64-linux.tar.gz"
      sha256 "d1a998389da9b9c9bbf6d04e09322bd19d05bdacd0849b7455ecf209543a64b6"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.7.0/zinq-0.7.0-x86_64-linux.tar.gz"
      sha256 "892619ece3268e0a67694981cfb1ea534a60670f30267bece3d11ea54575562b"
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
