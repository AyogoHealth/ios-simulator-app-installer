struct Simulator {
    let identifierString: String

    static func allSimulators() -> [Simulator] {
        return Shell.run(command: "xcrun instruments -s")
            .filterSimulators()
            .map { $0.truncateUuid() }
            .sorted { $0 > $1 }
            .map { Simulator(identifierString: $0) }
    }

    static func simulatorsMatchingIdentifier(_ identifier: String) -> [Simulator] {
        let all = allSimulators()
        guard identifier.characters.count > 0 else { return all }
        return all.filter { simulator in
            return simulator.identifierString.contains(identifier)
        }
    }
}

extension Collection where Iterator.Element == String {
    func filterSimulators() -> [String] {
        return filter { $0.contains("iPhone") || $0.contains("iPad") }
    }
}

extension String {
    func truncateUuid() -> String {
        let endMinus38 = characters.index(endIndex, offsetBy: -38)
        return substring(to: endMinus38)
    }
}
