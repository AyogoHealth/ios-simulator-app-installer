import Foundation

struct Simulator {
    let identifierString: String
    var name: String { return identifierString.truncateUuid() }

    static func allSimulators() -> [Simulator] {
        return Shell.run(command: "xcrun instruments -s devices")
            .filterSimulators()
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
        let result = components(separatedBy: " [")
        return result[0]
    }
}
