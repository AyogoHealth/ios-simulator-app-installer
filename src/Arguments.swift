class Arguments: GBSettings {
    let appFlag = "app"
    let deviceFlag = "device"
    let outFlag = "out"
    let packageLauncherFlag = "package-launcher"
    let listDevicesFlag = "list-devices"
    let freshInstallFlag = "fresh-install"
    let helpFlag = "help"

    var displayHelp: Bool {
        get { return isKeyPresent(atThisLevel: helpFlag) }
    }
    
    var shouldUninstallApp: Bool {
        get { return isKeyPresent(atThisLevel: freshInstallFlag) }
    }

    var listDevices: Bool {
        get { return isKeyPresent(atThisLevel: listDevicesFlag) }
    }
    
    var appPath: String? {
        get { return object(forKey: appFlag) as? String }
    }
    
    var deviceIdentifier: String? {
        get { return object(forKey: deviceFlag) as? String }
    }
    
    var outputPath: String? {
        get { return object(forKey: outFlag) as? String }
    }
    
    var packageLauncherPath: String? {
        get { return object(forKey: packageLauncherFlag) as? String }
    }

    func parse() -> GBOptionsHelper {
        let parser = GBCommandLineParser()
        let options = GBOptionsHelper()

        options.registerSeparator("NEW INSTALLER")
        options.registerOption("a".cChar(), long: appFlag, description: ".app for the installer", flags: GBOptionFlags())
        options.registerOption("d".cChar(), long: deviceFlag, description: "restrict installer to certain simulators, will be matched with --list-devices on launch", flags: GBOptionFlags())
        options.registerOption("o".cChar(), long: outFlag, description: "output path for the created installer", flags: GBOptionFlags())
        options.registerOption("f".cChar(), long: freshInstallFlag, description: "every launch of the installer will  result in a fresh install of the app", flags: .noValue)
        options.registerSeparator("DEVICES")
        options.registerOption("l".cChar(), long: listDevicesFlag, description: "list currently available device identifiers", flags: .noValue)
        options.registerSeparator("HELP")
        options.registerOption("h".cChar(), long: helpFlag, description: "print out this help", flags: .noValue)
        options.registerOption("p".cChar(), long: packageLauncherFlag, description: "use a path for app-package-launcher instead of the default in /usr/local/share", flags: .invisible)

        parser.register(self)
        parser.registerOptions(options)

        parser.parseOptionsUsingDefaultArguments()
        
        return options
    }
}
