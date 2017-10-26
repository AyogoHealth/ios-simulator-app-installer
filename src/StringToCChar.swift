extension String {
    func cChar() -> CChar {
        return cString(using: String.Encoding.utf8)!.first!
    }
}
