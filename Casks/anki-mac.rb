# frozen_string_literal: true

# Edited here by hand. Each AnkiMac release rewrites only the version and
# sha256 lines (the release workflow in davidmaniliuc/anki-mac).
cask "anki-mac" do
  version "0.1.0"
  sha256 "9b7ed6aec5b7a7ef86c15a3c6643d52e9955273b39aca90259ab8466a5a5169b"

  url "https://github.com/davidmaniliuc/anki-mac/releases/download/v#{version}/AnkiMac-#{version}.dmg"
  name "AnkiMac"
  desc "Native macOS frontend for Anki (alpha)"
  homepage "https://github.com/davidmaniliuc/anki-mac"

  livecheck do
    url :url
    strategy :github_releases
  end

  # The app updates itself through Sparkle, so brew upgrade leaves it alone.
  auto_updates true
  # The Rust backend is built for arm64 only; the deployment target is macOS 26.
  depends_on arch: :arm64
  depends_on macos: :tahoe

  app "AnkiMac.app"

  # The app is not notarized, so Gatekeeper refuses to open a quarantined
  # copy; stripping the attribute makes a Homebrew install open with no
  # prompt. must_succeed: false because the attribute is absent after
  # `--no-quarantine` or a reinstall. Drop this block once releases are
  # notarized (docs/RELEASING.md in the app's repo).
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/AnkiMac.app"],
        must_succeed:   false,
        print_stderr:   false,
        writable_paths: ["AnkiMac.app"],
        writable_base:  :appdir
  end

  zap trash: [
    "~/Library/Application Support/AnkiMac",
    "~/Library/Caches/io.github.davidmaniliuc.AnkiMac",
    "~/Library/HTTPStorages/io.github.davidmaniliuc.AnkiMac",
    "~/Library/Preferences/io.github.davidmaniliuc.AnkiMac.plist",
    "~/Library/Saved Application State/io.github.davidmaniliuc.AnkiMac.savedState",
    "~/Library/WebKit/io.github.davidmaniliuc.AnkiMac",
  ]

  caveats <<~EOS
    AnkiMac is ALPHA software. Back up your collection, or sync it to
    AnkiWeb, before opening one you care about.

    AnkiMac is not notarized by Apple. This cask removes the
    com.apple.quarantine attribute after install so that macOS opens it
    without the "Apple cannot check it for malicious software" prompt.

    `brew uninstall --zap anki-mac` also deletes your AnkiMac collections
    in ~/Library/Application Support/AnkiMac.
  EOS
end
