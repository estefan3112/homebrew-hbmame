class Hbmame < Formula
  desc "HomeBrew MAME: hacks, homebrew and prototypes for the MAME emulator"
  homepage "https://hbmame.1emulation.com/"
  url "https://github.com/Robbbert/hbmame/archive/refs/tags/tag2894.tar.gz"
  version "0.289.4"
  # The "Bump HBMAME" workflow fills in the real checksum. Do not edit by hand.
  sha256 "2995bcfcc655ea3de186d2dba8e27be7ffa8115ca3bb2c48b6c1a653ae910bb4"
  license "GPL-2.0-or-later"
  head "https://github.com/Robbbert/hbmame.git", branch: "master"

  # HBMAME tags look like `tag2894`, meaning version 0.289.4.
  livecheck do
    url :stable
    regex(/^tag(\d{3})(\d+)$/i)
    strategy :git do |tags, regex|
      tags.filter_map do |tag|
        match = tag.match(regex)
        "0.#{match[1]}.#{match[2]}" if match
      end
    end
  end

  bottle do
    root_url "https://github.com/estefan3112/homebrew-hbmame/releases/download/hbmame-0.289.4"
    sha256 cellar: :any, arm64_tahoe:   "ddced544ca059da66c7d40889729ad25230e97dd041b0bf337a2b0a62d596c0c"
    sha256 cellar: :any, arm64_sequoia: "542fed2ae28787ca40ae1bd181ae3ce53be7e7ef45f8bf9031e3ef5aeb163895"
  end

  depends_on "pkgconf" => :build
  depends_on :macos
  depends_on "sdl3"

  uses_from_macos "python" => :build

  def install
    # Homebrew's sdl3 ships no static libraries, so drop the `--static` flag
    # (same fix as Homebrew's own mame formula).
    inreplace "scripts/src/osd/sdl.lua", "--static", ""

    # Unlike Homebrew's mame formula, the 3rd-party libraries bundled with
    # HBMAME are used (the proven macOS build). Only SDL3 comes from Homebrew.
    system "make", "PYTHON_EXECUTABLE=#{which("python3")}",
                   "TARGET=hbmame",
                   "USE_LIBSDL=1",
                   "OSD=sdl3",
                   "VERBOSE=1"
    bin.install "hbmame"

    # Runtime folders, laid out like Homebrew MAME's share/mame.
    data = %w[artwork bgfx ctrlr hash ini language plugins samples uismall.bdf]
    pkgshare.install data.select { |f| File.exist?(f) }
  end

  def caveats
    <<~EOS
      HBMAME's runtime folders (bgfx, plugins, hash, language, artwork, ...) are in:
        #{HOMEBREW_PREFIX}/share/hbmame

      Point your hbmame.ini at them, the same way as for Homebrew MAME, e.g.:
        hashpath      #{HOMEBREW_PREFIX}/share/hbmame/hash
        pluginspath   #{HOMEBREW_PREFIX}/share/hbmame/plugins
        languagepath  #{HOMEBREW_PREFIX}/share/hbmame/language
        bgfx_path     #{HOMEBREW_PREFIX}/share/hbmame/bgfx

      Create a fresh hbmame.ini by running `hbmame -createconfig` in an empty folder.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hbmame -help")
    # 1942 is a parent set in HBMAME; listing it proves the driver list is built in.
    assert_match "1942", shell_output("#{bin}/hbmame -listfull 1942")
  end
end
