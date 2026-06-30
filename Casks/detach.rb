cask "detach" do
  version "0.1.0"
  sha256 "a4c91eb2b68706c008787704246195990020ecb5551d19e9d753594e6363cd0c"

  url "https://github.com/arlkn/Detach/releases/download/v#{version}/Detach.dmg"
  name "Detach"
  desc "Native macOS app uninstaller that moves apps and related files to Trash"
  homepage "https://github.com/arlkn/Detach"

  app "Detach.app"
end
