import Cocoa
import Foundation

class Installer {

    static func installAndRunApp(_ packagedApp: PackagedApp, simulator: Simulator) {
        DispatchQueue.global().async {
            shutDownCurrentSimulatorSessions()

            _ = Shell.run(command: "xcrun instruments -w \"\(simulator.identifierString)\"")

            if Parameters.shouldUninstallFirst() {
                _ = Shell.run(command: "xcrun simctl uninstall booted \(packagedApp.bundleIdentifier)")
            }

            _ = Shell.run(command: "xcrun simctl install booted \"\(packagedApp.bundlePath)\"")
            _ = Shell.run(command: "xcrun simctl launch booted \(packagedApp.bundleIdentifier)")

            NSApplication.shared().terminate(nil)
        }
    }

    static func shutDownCurrentSimulatorSessions() {
        _ = Shell.run(command: "killall \"Simulator\"")
        _ = Shell.run(command: "xcrun simctl shutdown booted")
    }

}
