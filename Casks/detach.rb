cask "detach" do
  version "0.1.2"
  sha256 "796cd6fcd039f7df107fe41fdeb83be8a5799601aa0f2d64b37a4df667b341db"

  url "https://github.com/arlkn/Detach/releases/download/v#{version}/Detach.dmg"
  name "Detach"
  desc "Native macOS app uninstaller that moves apps and related files to Trash"
  homepage "https://github.com/arlkn/Detach"

  app "Detach.app"
end
