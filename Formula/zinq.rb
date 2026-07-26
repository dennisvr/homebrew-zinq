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
  version "0.2.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.2.1/zinq-0.2.1-arm64-apple-darwin.tar.gz"
      sha256 "315347e7f331c43740b7b4de1417d9b85be3eadbf7578ac1a16acbadd380f612"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.2.1/zinq-0.2.1-x86_64-apple-darwin.tar.gz"
      sha256 "49f1d6447f43b20dc50eb9d5b473cac36ff904f82729fd5cf77fc247442a5826"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.2.1/zinq-0.2.1-aarch64-linux.tar.gz"
      sha256 "025715c2ed7030ddd35bb15e2df4008bf94df2257cd3b97e45bce0360715e30c"
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v0.2.1/zinq-0.2.1-x86_64-linux.tar.gz"
      sha256 "b14cf2419a44f5eda00eec0e1617fde1e308ac7d2486022d7164f873216244ce"
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
