import Foundation

enum PackagedAppError: Error {
    case bundleNotFound
    case infoPlistNotFound
    case bundleIdentifierNotFound

    var asNSError: NSError {
        let description: String
        switch self {
        case .bundleNotFound: description = "App bundle couldn't be found, this installer was packaged incorrectly."
        case .infoPlistNotFound: description = "Info.plist not found in packaged app, this installer was packaged incorrectly."
        case .bundleIdentifierNotFound: description = "Bundle identifier not found in packaged app's Info.plist, this installer was packaged incorrectly."
        }

        return  NSError(
            domain: "com.stepanhruda.ios-simulator-app-installer",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey as NSString: description])
    }
}

struct PackagedApp {
    let bundleName: String
    let bundlePath: String
    let bundleIdentifier: String
    
    init(bundleName: String) throws {
        guard let bundlePath = PackagedApp.pathForFileNamed(bundleName) else { throw PackagedAppError.bundleNotFound }
        guard let infoPlist = PackagedApp.infoPlistInBundleWithPath(bundlePath) else { throw PackagedAppError.infoPlistNotFound }
        guard let bundleIdentifier = PackagedApp.bundleIdentifierFromInfoPlist(infoPlist) else { throw PackagedAppError.bundleIdentifierNotFound }

        self.bundlePath = bundlePath
        self.bundleName = bundleName
        self.bundleIdentifier = bundleIdentifier
    }

    static func pathForFileNamed(_ filename: String) -> String? {
        return Bundle.main.path(forResource: filename, ofType: "app")
    }

    static func infoPlistInBundleWithPath(_ bundlePath: String) -> NSDictionary? {
        return NSDictionary(contentsOfFile: bundlePath + "/Info.plist")
    }

    static func bundleIdentifierFromInfoPlist(_ infoPlist: NSDictionary) -> String? {
        return infoPlist.object(forKey: kCFBundleIdentifierKey) as? String
    }
}
