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
  version "0.3.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.3.0/zinq-0.3.0-arm64-apple-darwin.tar.gz"
      sha256 "4a92e339fac3b3ddc2cff57e62b07696f3b2d938faf1fe40c6ee39da3825201c"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.3.0/zinq-0.3.0-x86_64-apple-darwin.tar.gz"
      sha256 "e0c02f6a2ce60cebf3338dc09d53d2ada70a308334dd45a2185c4e14bdb900d5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.3.0/zinq-0.3.0-aarch64-linux.tar.gz"
      sha256 "e1b1484c73f59b9f506fc42da3eb42c655427b89e9f508f394714c9c347218d8"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.3.0/zinq-0.3.0-x86_64-linux.tar.gz"
      sha256 "7b27c8fb173e20c0201b7ab26bb76f09cbd8235adc003d55bb8be0449a8f6c26"
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
