cask "detach" do
  version "0.1.1"
  sha256 "ca3d72ceb6be56d5d429406644a12e29a307db1dcd6fbf81ee6771c7a4280e86"

  url "https://github.com/arlkn/Detach/releases/download/v#{version}/Detach.dmg"
  name "Detach"
  desc "Native macOS app uninstaller that moves apps and related files to Trash"
  homepage "https://github.com/arlkn/Detach"

  app "Detach.app"
end
