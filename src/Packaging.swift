enum PackagingError: Error {
    case requiredXcodeUnavailable(String)
    case invalidAppPath(String)
    case xcodebuildFailed
    case fileWriteFailed(NSError)

    var message: String {
        switch self {
        case .requiredXcodeUnavailable(let requiredVersion):
            return "You need to have \(requiredVersion) installed and selected via xcode-select."
        case .invalidAppPath(let path):
            return "Provided .app not found at \(path)"
        case .xcodebuildFailed:
            return "Error in xcodebuild when packaging app"
        case .fileWriteFailed(let error):
            return "Writing output bundle failed: \(error.localizedDescription)"
        }
    }
}

class Packaging {

    static func packageAppAtPath(
        _ appPath: String,
        deviceIdentifier: String?,
        outputPath outputPathMaybe: String?,
        packageLauncherPath packageLauncherPathMaybe: String?,
        shouldUninstall: Bool,
        fileManager: FileManager) throws {
            let packageLauncherPath = packageLauncherPathMaybe ?? "/usr/local/share/app-package-launcher"

            guard Xcode.isRequiredVersionInstalled() else { throw PackagingError.requiredXcodeUnavailable(Xcode.requiredVersion) }
            guard fileManager.fileExists(atPath: appPath) else { throw PackagingError.invalidAppPath(appPath) }
            let fullAppPath = URL(fileURLWithPath: appPath).path

            let outputPath = outputPathMaybe ?? defaultOutputPathForAppPath(appPath)

            let productFolder = "\(packageLauncherPath)/build"
            let productPath = "\(productFolder)/Release/app-package-launcher.app"
            let packagedAppFlag = "PACKAGED_APP=\(fullAppPath)"
            let targetDeviceFlag = deviceIdentifier != nil ? "\"TARGET_DEVICE=\(deviceIdentifier!)\"" : ""
            let uninstallFlag = shouldUninstall ? "UNINSTALL=1" : ""



            let task = ShellTask(launchPath: "/usr/bin/xcodebuild")
            task.arguments = [
                "-project", "\(packageLauncherPath)/app-package-launcher.xcodeproj",
                packagedAppFlag,
                targetDeviceFlag,
                uninstallFlag,
            ].filter({ $0 != "" })
            task.outputOptions = [
                .print(prefix: "OUT")
            ]
            task.errorOptions = [
                .print(prefix: "ERR")
            ]

            print("command:", task.command)

            task.launch { result in
        
                switch result {
                case .success:
                    break
                case let .failure(code):
                    print("failed:", code)
                }

            }

            task.waitUntilExit()

            guard task.terminationStatus == 0 else { throw PackagingError.xcodebuildFailed }

            do {
                if fileManager.fileExists(atPath: outputPath) {
                    try fileManager.removeItem(atPath: outputPath)
                }
                try fileManager.moveItem(atPath: productPath, toPath: outputPath)
                try fileManager.removeItem(atPath: productFolder)
            } catch let error as NSError {
                throw PackagingError.fileWriteFailed(error)
            }

            print("\(appPath) successfully packaged to \(outputPath)")
    }

    static func defaultOutputPathForAppPath(_ appPath: String) -> String {
        let url = URL(fileURLWithPath: appPath)
        let appName = url.deletingPathExtension().lastPathComponent 
        return "\(appName) Installer.app"
    }

}
