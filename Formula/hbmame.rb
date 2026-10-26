class Hbmame < Formula
  desc "HomeBrew MAME: hacks, homebrew and prototypes for the MAME emulator"
  homepage "https://hbmame.1emulation.com/"
  url "https://github.com/Robbbert/hbmame/archive/refs/tags/tag2894.tar.gz"
  version "0.289.4"
  # The "Bump HBMAME" workflow fills in the real checksum. Do not edit by hand.
  sha256 "2995bcfcc655ea3de186d2dba8e27be7ffa8115ca3bb2c48b6c1a653ae910bb4"
  license "GPL-2.0-or-later"
  revision 2
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
    sha256 cellar: :any, arm64_tahoe:   "90ac9b38f26786b3c325d7b086b3da4d00c7aaf20241bc3684b64a99c50ae62d"
    sha256 cellar: :any, arm64_sequoia: "ef021cc63461668411429c3a3491e5829ad5a85648dd787db5f66a3cfe72fa2b"
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

    # `hbmame-setup`: a one-time helper the user runs to create their own
    # folder and a starter hbmame.ini. (A formula must not write into
    # anyone's home folder itself.)
    setup = (buildpath/"hbmame-setup.sh")
    setup.write <<~'SH'
      #!/bin/sh
      # Creates ~/Library/Application Support/hbmame with its sub-folders and
      # a starter hbmame.ini pointing at the Homebrew support files.
      # An existing hbmame.ini is never changed.
      set -e
      DIR="$HOME/Library/Application Support/hbmame"
      SHARE="@@SHARE@@"
      BIN="@@BIN@@"

      mkdir -p "$DIR"
      cd "$DIR"
      for d in roms ini cfg nvram inp sta snap diff comments artwork samples \
               ctrlr fonts cheat crosshair software; do
        mkdir -p "$d"
      done

      if [ -e hbmame.ini ]; then
        echo "Folders checked. Existing hbmame.ini in $DIR left unchanged."
        exit 0
      fi

      "$BIN" -noreadconfig -createconfig \
        -homepath "$DIR" \
        -rompath "$DIR/roms" \
        -hashpath "$SHARE/hash" \
        -samplepath "$DIR/samples;$SHARE/samples" \
        -artpath "$DIR/artwork;$SHARE/artwork" \
        -ctrlrpath "$DIR/ctrlr;$SHARE/ctrlr" \
        -inipath "$DIR;$DIR/ini" \
        -fontpath "$DIR/fonts" \
        -cheatpath "$DIR/cheat" \
        -crosshairpath "$DIR/crosshair" \
        -pluginspath "$SHARE/plugins" \
        -languagepath "$SHARE/language" \
        -swpath "$DIR/software" \
        -cfg_directory "$DIR/cfg" \
        -nvram_directory "$DIR/nvram" \
        -input_directory "$DIR/inp" \
        -state_directory "$DIR/sta" \
        -snapshot_directory "$DIR/snap" \
        -diff_directory "$DIR/diff" \
        -comment_directory "$DIR/comments" \
        -bgfx_path "$SHARE/bgfx"

      # -noreadconfig above must not end up in the saved file.
      sed -i '' 's/^readconfig .*/readconfig                1/' hbmame.ini

      # -createconfig writes an empty plugin.ini (same in upstream MAME),
      # which hbmame then reports as "Error loading plugin.ini". Without the
      # file, the default plugins load; hbmame writes plugin.ini itself as soon
      # as plugins are changed in its Plugin Options menu.
      rm -f plugin.ini

      echo "Created $DIR/hbmame.ini"
      echo "Put your HBMAME ROMs into $DIR/roms (or edit rompath in hbmame.ini)."
    SH
    inreplace setup do |s|
      s.gsub! "@@SHARE@@", "#{HOMEBREW_PREFIX}/share/hbmame"
      s.gsub! "@@BIN@@", "#{HOMEBREW_PREFIX}/bin/hbmame"
    end
    bin.install setup => "hbmame-setup"
  end

  def caveats
    <<~EOS
      First-time setup: run once

        hbmame-setup

      It creates ~/Library/Application Support/hbmame with its sub-folders and a
      starter hbmame.ini that already points at HBMAME's support files in
        #{HOMEBREW_PREFIX}/share/hbmame
      An existing hbmame.ini is left unchanged.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hbmame -help")
    # 1942 is a parent set in HBMAME; listing it proves the driver list is built in.
    assert_match "1942", shell_output("#{bin}/hbmame -listfull 1942")

    # hbmame-setup creates the user folder and a starter hbmame.ini.
    ENV["HOME"] = testpath
    system bin/"hbmame-setup"
    ini = testpath/"Library/Application Support/hbmame/hbmame.ini"
    assert_path_exists ini
    assert_match "share/hbmame/hash", ini.read
    assert_match(/^readconfig\s+1$/, ini.read)
    plugin_ini = testpath/"Library/Application Support/hbmame/plugin.ini"
    refute_path_exists plugin_ini
  end
end
