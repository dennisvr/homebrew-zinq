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
  version "0.4.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.4.1/zinq-0.4.1-arm64-apple-darwin.tar.gz"
      sha256 "287ffc0ff888c263bc89d6770311dcc919b8066c4e0bca350c5583e670c63ee4"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.4.1/zinq-0.4.1-x86_64-apple-darwin.tar.gz"
      sha256 "0f232e39bff5cf932dc4fc33906bfdc1943d99c222a9e9a8ed3177eb9928926a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.4.1/zinq-0.4.1-aarch64-linux.tar.gz"
      sha256 "fd08a5d342a5b01fe1e7d940e09fe9e27768f7966c61740fa1ddf0230c8a66c4"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.4.1/zinq-0.4.1-x86_64-linux.tar.gz"
      sha256 "df8fc607f8ebc291a2bb23fc6e42a147f104c6ed18a227802ea526dc70085d23"
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
