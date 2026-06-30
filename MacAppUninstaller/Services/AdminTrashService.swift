import Foundation

protocol AdminTrashServicing {
    func moveAdminItemToTrash(_ url: URL, currentUserHome: URL) throws -> URL
}

enum AdminTrashError: LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .failed(let message):
            return message.isEmpty ? "Administrator authorization was cancelled or failed." : message
        }
    }
}

final class AdminTrashService: AdminTrashServicing {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func moveAdminItemToTrash(_ url: URL, currentUserHome: URL) throws -> URL {
        let trashDirectory = currentUserHome.appendingPathComponent(".Trash", isDirectory: true)
        try fileManager.createDirectory(at: trashDirectory, withIntermediateDirectories: true)
        let destination = uniqueDestination(for: url, in: trashDirectory)

        let command = "/bin/mv \(shellQuoted(url.path)) \(shellQuoted(destination.path))"
        let script = "do shell script \(appleScriptString(command)) with administrator privileges"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let errorPipe = Pipe()
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            throw AdminTrashError.failed(message)
        }

        return destination
    }

    private func uniqueDestination(for source: URL, in trashDirectory: URL) -> URL {
        let baseName = source.lastPathComponent
        var candidate = trashDirectory.appendingPathComponent(baseName)
        guard fileManager.fileExists(atPath: candidate.path) else { return candidate }

        let name = source.deletingPathExtension().lastPathComponent
        let pathExtension = source.pathExtension
        var index = 2

        repeat {
            let filename = pathExtension.isEmpty ? "\(name) \(index)" : "\(name) \(index).\(pathExtension)"
            candidate = trashDirectory.appendingPathComponent(filename)
            index += 1
        } while fileManager.fileExists(atPath: candidate.path)

        return candidate
    }

    private func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    private func appleScriptString(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
    }
}
