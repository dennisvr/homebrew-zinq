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
  version "0.8.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.8.0/zinq-0.8.0-arm64-apple-darwin.tar.gz"
      sha256 "921011592cf04872cb000040c3cf6014c2238ef3d203b27bc54e4dfb158a2299"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.8.0/zinq-0.8.0-x86_64-apple-darwin.tar.gz"
      sha256 "6540b6c5dc3c389947dc1f30811d572ef256735f42c257d337534c86cc5552af"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.8.0/zinq-0.8.0-aarch64-linux.tar.gz"
      sha256 "ea0264e0731c2fbfc9eba8acb4f034c54cd25cf11e47599513b350898fbd2243"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.8.0/zinq-0.8.0-x86_64-linux.tar.gz"
      sha256 "557a42f1800856fccf7713d48f61be576dbe8fc5a28d0db1dd410cb445ead891"
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
