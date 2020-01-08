// @copyright Trollwerks Inc.

extension Data: ServiceProvider {

    /// Create by loading from disk cache
    /// - Parameter filename: Name
    init?(cache filename: String) {
        self.init(directory: Self.cachesDirectory,
                  filename: filename)
    }

    /// Create by loading from disk documents
    /// - Parameter filename: Name
    init?(docs filename: String) {
        self.init(directory: Self.docsDirectory,
                  filename: filename)
    }

    /// Create by loading from directory
    /// - Parameter directory: Directory
    /// - Parameter filename: Name
    init?(directory: URL,
          filename: String) {
        let url = directory.appendingPathComponent(filename)
        do {
            self = try Data(contentsOf: url)
        } catch {
            Services().log.error("Loading \(filename) failed: \(error)")
            return nil
        }
    }

    /// Saves file to disk cache
    /// - Parameter filename: Name
    func save(cache filename: String) {
        save(directory: Self.cachesDirectory,
             filename: filename)
    }

    /// Saves file to disk documents
    /// - Parameter filename: Name
    func save(docs filename: String) {
        save(directory: Self.docsDirectory,
             filename: filename)
    }

    /// Saves file to disk
    /// - Parameters:
    ///   - directory: Enclosing directory
    ///   - filename: Name
    func save(directory: URL,
              filename: String) {
        let url = directory.appendingPathComponent(filename)
        do {
            try write(to: url, options: [.atomic])
        } catch {
            log.error("Saving \(filename) failed: \(error)")
        }
    }

    /// Deletes file from disk cache
    /// - Parameter filename: Name
    func delete(cache filename: String) {
        delete(directory: Self.cachesDirectory,
               filename: filename)
    }

    /// Deletes file from disk documents
    /// - Parameter filename: Name
    func delete(docs filename: String) {
        delete(directory: Self.docsDirectory,
               filename: filename)
    }

    private func delete(directory: URL,
                        filename: String) {
        let url = directory.appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            log.error("Deleting \(filename) failed: \(error)")
        }
    }

    /// Convenience accessor for caches directory
    static var cachesDirectory: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory,
                                             in: .userDomainMask)
        return paths[0]
    }

    /// Convenience accessor for user documents directory
    static var docsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        return paths[0]
    }
}
