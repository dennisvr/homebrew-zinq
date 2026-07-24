class Zinq < Formula
  desc "jq-compatible JSON and YAML processor"
  homepage "https://github.com/dennisvr/homebrew-zinq" # TODO: swap for a project page if one exists
  version "0.1.0" # TODO: real version
  license "Apache-2.0" # source license; adjust if the binary ships under other terms

  on_macos do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v#{version}/zinq-#{version}-arm64-apple-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000" # TODO: fill from release
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v#{version}/zinq-#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000" # TODO: fill from release
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v#{version}/zinq-#{version}-aarch64-linux.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000" # TODO: fill from release
    end
    on_intel do
      url "https://github.com/dennisvr/homebrew-zinq/releases/download/v#{version}/zinq-#{version}-x86_64-linux.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000" # TODO: fill from release
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
