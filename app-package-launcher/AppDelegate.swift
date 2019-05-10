import AppKit
import Cocoa

enum SimulatorDeviceError: LocalizedError {
    case noSuitableDevice(target: String)
    
    public static var errorDomain: String {
        return "com.stepanhruda.ios-simulator-app-installer"
    }
    
    public var errorCode: Int {
        return 2
    }
    
    public var errorDescription: String? {
        switch self {
        case .noSuitableDevice(let target):
            return "No simulator matching \"\(target)\" was found."
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            let packagedApp = try PackagedApp(bundleName: "Packaged")

            let simulatorIdentifierProvidedOnCompileTime = Parameters.deviceString()
            let simulators = Simulator.simulatorsMatchingIdentifier(simulatorIdentifierProvidedOnCompileTime)

            switch simulators.count {

            case 1:

                Installer.installAndRunApp(packagedApp, simulator: simulators.first!)

            case _ where simulators.count > 1:

                letUserSelectSimulatorFrom(simulators) { selectedSimulator in
                    Installer.installAndRunApp(packagedApp, simulator: selectedSimulator)
                }

            default:

                terminateWithError(SimulatorDeviceError.noSuitableDevice(target: simulatorIdentifierProvidedOnCompileTime))
            }
        }
        catch let error as PackagedAppError {
            terminateWithError(error)
        } catch {
            fatalError("error handling failure")
        }
    }
    
    var simulatorSelectionController: SimulatorSelectionWindowController?

    func letUserSelectSimulatorFrom(_ simulators: [Simulator], completion: @escaping (Simulator) -> Void) {
        simulatorSelectionController = SimulatorSelectionWindowController.controller(simulators) {
            [unowned self] selectedSimulator in
            completion(selectedSimulator)
            self.simulatorSelectionController = nil
        }
        simulatorSelectionController?.showWindow(nil)
    }

    func terminateWithError(_ error: Error) {
        NSAlert(error: error).runModal()
        NSApplication.shared.terminate(nil)
    }
}
