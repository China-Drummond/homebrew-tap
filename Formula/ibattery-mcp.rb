class IbatteryMcp < Formula
  desc "MCP server exposing Apple device battery status as AI-assistant tools"
  homepage "https://github.com/China-Drummond/ibattery-mcp"
  url "https://github.com/China-Drummond/ibattery-mcp/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "3e72d5a11d1b670931ac96fbeea9bdf970d17a0f3bc80161d77123e003c80f5a"
  license "MIT"

  depends_on "pkg-config" => :build
  depends_on xcode: ["15.0", :build]
  depends_on "libimobiledevice"

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/ibattery-mcp"

    system "./Scripts/build-ble-helper-app.sh"
    libexec.install ".build/ibattery-ble-helper.app"
  end

  def caveats
    <<~EOS
      ibattery-mcp needs a companion helper app running for Bluetooth device
      support (macOS requires this to be a separately-launched app, not a
      bare subprocess -- see the project README for why). Launch it once with:

        open "#{opt_libexec}/ibattery-ble-helper.app"

      It stays running in the background afterward. You'll also need to
      connect any iPhone/iPad you want battery info from via USB at least
      once, to establish trust.
    EOS
  end

  test do
    # ibattery-mcp is a stdio JSON-RPC MCP server, not a traditional CLI tool.
    # --help is a small dedicated flag added specifically to give `brew test`
    # a fast, deterministic smoke check without needing to speak the MCP
    # handshake protocol over stdin.
    assert_match "ibattery-mcp", shell_output("#{bin}/ibattery-mcp --help")
  end
end
