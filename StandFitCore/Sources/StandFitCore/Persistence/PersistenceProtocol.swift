//
//  PersistenceProtocol.swift
//  StandFitCore
//
//  Platform-agnostic persistence layer
//

import Foundation

// MARK: - Persistence Protocol

/// Abstract persistence layer for storing and retrieving data
/// Implementations can use JSON files, Core Data, CloudKit, etc.
public protocol PersistenceProvider {
    /// Save codable data to persistent storage
    func save<T: Codable>(_ data: T, forKey key: String) throws

    /// Load codable data from persistent storage
    func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T?

    /// Delete data for a specific key
    func delete(forKey key: String) throws

    /// Check if data exists for a key
    func exists(forKey key: String) -> Bool
}

// MARK: - Persistence Errors

public enum PersistenceError: Error, LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case fileNotFound(String)
    case saveFailed(String)
    case deleteFailed(String)

    public var errorDescription: String? {
        switch self {
        case .encodingFailed(let message):
            return "Failed to encode data: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode data: \(message)"
        case .fileNotFound(let key):
            return "File not found for key: \(key)"
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete data: \(message)"
        }
    }
}

// MARK: - JSON File Persistence Implementation

/// Default implementation using JSON files in the Documents directory
public class JSONFilePersistence: PersistenceProvider {
    private let fileManager: FileManager
    private let documentsDirectory: URL

    public init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager

        // Get documents directory for the platform
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw PersistenceError.saveFailed("Could not access documents directory")
        }
        self.documentsDirectory = documentsPath
    }

    private func fileURL(forKey key: String) -> URL {
        documentsDirectory.appendingPathComponent("\(key).json")
    }

    public func save<T: Codable>(_ data: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(data)
            let fileURL = fileURL(forKey: key)
            try jsonData.write(to: fileURL, options: .atomic)
        } catch let error as EncodingError {
            throw PersistenceError.encodingFailed(error.localizedDescription)
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }

    public func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        let fileURL = fileURL(forKey: key)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw PersistenceError.decodingFailed(error.localizedDescription)
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }

    public func delete(forKey key: String) throws {
        let fileURL = fileURL(forKey: key)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return // Already deleted
        }

        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw PersistenceError.deleteFailed(error.localizedDescription)
        }
    }

    public func exists(forKey key: String) -> Bool {
        let fileURL = fileURL(forKey: key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
}
