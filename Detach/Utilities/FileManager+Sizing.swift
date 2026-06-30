import Foundation

extension FileManager {
    func allocatedSizeOfItem(at url: URL) -> Int64 {
        guard let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey]) else {
            return 0
        }

        if resourceValues.isDirectory == true {
            return allocatedSizeOfDirectory(at: url)
        }

        return Int64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }

    func isSymbolicLink(at url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true
    }

    private func allocatedSizeOfDirectory(at url: URL) -> Int64 {
        guard let enumerator = enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        return enumerator.reduce(Int64(0)) { partial, item in
            guard let itemURL = item as? URL,
                  let values = try? itemURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]) else {
                return partial
            }
            return partial + Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
        }
    }
}
