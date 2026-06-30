import Foundation

struct MatchTokens {
    let appName: String
    let bundleIdentifier: String?

    var normalizedAppName: String {
        Self.normalize(appName)
    }

    var bundleParts: [String] {
        guard let bundleIdentifier else { return [] }
        return bundleIdentifier
            .split(separator: ".")
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    var reversedDomainName: String? {
        guard bundleParts.count >= 2 else { return nil }
        return bundleParts.reversed().joined(separator: ".")
    }

    var searchableTokens: [String] {
        var tokens = [normalizedAppName]
        if let bundleIdentifier {
            tokens.append(bundleIdentifier.lowercased())
        }
        if let reversedDomainName {
            tokens.append(reversedDomainName.lowercased())
        }
        tokens.append(contentsOf: bundleParts.map { $0.lowercased() })
        return Array(Set(tokens.filter { $0.count >= 3 }))
    }

    static func normalize(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: ".app", with: "")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

final class RiskClassifier {
    private let protectedPrefixes = ["/System", "/bin", "/usr", "/sbin", "/private/etc"]

    func classify(url: URL, kind: RelatedFileKind, tokens: MatchTokens, isSystemWide: Bool, isSymbolicLink: Bool) -> (FileConfidence, String) {
        let standardizedPath = url.standardizedFileURL.path
        guard !protectedPrefixes.contains(where: { standardizedPath == $0 || standardizedPath.hasPrefix($0 + "/") }) else {
            return (.low, "Protected system path")
        }

        if isSymbolicLink {
            return (.low, "Symbolic link; target is not followed automatically")
        }

        let lowercasePath = standardizedPath.lowercased()
        let last = MatchTokens.normalize(url.deletingPathExtension().lastPathComponent)

        if let bundleID = tokens.bundleIdentifier?.lowercased(), lowercasePath.contains(bundleID) {
            return isSystemWide ? (.medium, "Bundle identifier match in system-wide location") : (.high, "Bundle identifier match")
        }

        if let reversed = tokens.reversedDomainName?.lowercased(), lowercasePath.contains(reversed) {
            return isSystemWide ? (.medium, "Reverse-domain name match in system-wide location") : (.medium, "Reverse-domain name match")
        }

        if !tokens.normalizedAppName.isEmpty && last == tokens.normalizedAppName {
            return isSystemWide ? (.low, "Application name match in system-wide location") : (.medium, "Application name match")
        }

        return (.low, "Weak or partial name match")
    }

    func isPlausibleMatch(url: URL, tokens: MatchTokens) -> Bool {
        let path = url.standardizedFileURL.path.lowercased()
        return tokens.searchableTokens.contains { token in
            path.contains(token)
        }
    }
}
