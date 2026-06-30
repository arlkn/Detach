import Foundation

protocol TrashServicing {
    func moveItemToTrash(_ url: URL) throws -> URL
}

final class WorkspaceTrashService: TrashServicing {
    func moveItemToTrash(_ url: URL) throws -> URL {
        var resultingURL: NSURL?
        try FileManager.default.trashItem(at: url, resultingItemURL: &resultingURL)
        guard let resultingURL = resultingURL as URL? else {
            throw CocoaError(.fileWriteUnknown)
        }
        return resultingURL
    }
}
