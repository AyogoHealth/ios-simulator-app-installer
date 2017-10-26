class IosSimulatorAppInstaller < Formula
  homepage "https://github.com/tcurdt/ios-simulator-app-installer"
  url "https://github.com/tcurdt/ios-simulator-app-installer.git", :tag => "0.3.0"
  version "0.3.0"

  depends_on :xcode => "8"
  depends_on :macos => :yosemite

  def install
    system "make"
    bin.install "ios-simulator-app-installer"
    share.install "app-package-launcher"
  end

  test do
    system "make"
  end
end
