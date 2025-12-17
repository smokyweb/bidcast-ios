//
//  CSVManager.swift
//  BidCast
//
//  Created by JamTech on 17/12/25.

//  CSV Download Manager for handling CSV file downloads from API

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - CSV Download Manager
class CSVDownloadManager: ObservableObject {
    
    static let shared = CSVDownloadManager()
    
    @Published var isDownloading: Bool = false
    @Published var downloadProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var downloadedFileURL: URL?
    
    private init() {}
    
    // MARK: - Download CSV from API
    /// Downloads CSV data from the export details API endpoint
    /// - Parameters:
    ///   - request: ExportDetailsRequest object containing filter parameters
    ///   - fileName: Optional custom file name (default: "export_data.csv")
    ///   - saveLocation: Where to save the file (downloads or temporary for sharing)
    /// - Returns: URL of the downloaded file
    @discardableResult
    func downloadCSV(
        request: ExportDetailsRequest,
        endPoint: EndPointType,
        fileName: String = "export_data.csv",
        saveLocation: SaveLocation = .downloads
    ) async throws -> URL {
        
        await MainActor.run {
            self.isDownloading = true
            self.downloadProgress = 0.0
            self.errorMessage = nil
            self.downloadedFileURL = nil
        }
        
        do {
            // Make API request to get CSV data
            let csvData = try await fetchCSVData(type: endPoint, request: request)
            
            await MainActor.run {
                self.downloadProgress = 0.5
            }
            
            // Save CSV data to file
            let fileURL = try saveCSVToFile(
                data: csvData,
                fileName: fileName,
                saveLocation: saveLocation
            )
            
            await MainActor.run {
                self.downloadProgress = 1.0
                self.isDownloading = false
                self.downloadedFileURL = fileURL
            }
            
            return fileURL
            
        } catch {
            await MainActor.run {
                self.isDownloading = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Fetch CSV Data from API
    private func fetchCSVData(type: EndPointType,request: ExportDetailsRequest) async throws -> Data {
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = type.method.rawValue
        
        if let parameters = type.body {
            request.httpBody = try? JSONEncoder().encode(parameters)
        }
        
        request.allHTTPHeaderFields = type.headers
        
        
        print("Current TimeZone: \(deviceTimeZone)")
        request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)","timezone":"\(deviceTimeZone)","time_zone":"\(deviceTimeZone)"]
        
        print("URL: ====>\(url)")
        print("METHOD: =====> \(type.method)")
        print("BODY: =====> \(type.body ?? "")")
        print(request.allHTTPHeaderFields as Any)
        
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 40
        config.requestCachePolicy = .useProtocolCachePolicy
        config.httpShouldUsePipelining = true
        
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CSVDownloadError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw CSVDownloadError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    // MARK: - Save CSV to File
    private func saveCSVToFile(
        data: Data,
        fileName: String,
        saveLocation: SaveLocation
    ) throws -> URL {
        
        let fileURL: URL
        
        switch saveLocation {
        case .downloads:
            // Save to app's shared container that's visible in Files app
            fileURL = try saveToDownloadsDirectory(data: data, fileName: fileName)
            
        case .temporary:
            // Save to temporary directory for immediate sharing
            fileURL = try saveToTempDirectory(data: data, fileName: fileName)
            
        case .documentsVisible:
            // Save to documents directory that's visible in Files app
            fileURL = try saveToVisibleDocuments(data: data, fileName: fileName)
        }
        
        return fileURL
    }
    
    // Save to app's visible documents folder (appears in Files app)
    private func saveToVisibleDocuments(data: Data, fileName: String) throws -> URL {
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw CSVDownloadError.fileSystemError
        }
        
        // Create Downloads subfolder
        let downloadsFolder = documentsURL.appendingPathComponent("Downloads", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: downloadsFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        let fileURL = downloadsFolder.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        
        return fileURL
    }
    
    // Save to Downloads directory (if available)
    private func saveToDownloadsDirectory(data: Data, fileName: String) throws -> URL {
        // For iOS, we'll use the app's container that's accessible via Files app
        // First, ensure the app has UIFileSharingEnabled and LSSupportsOpeningDocumentsInPlace in Info.plist
        
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw CSVDownloadError.fileSystemError
        }
        
        let fileURL = documentsURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        
        return fileURL
    }
    
    // Save to temporary directory for immediate sharing
    private func saveToTempDirectory(data: Data, fileName: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
    
    // MARK: - Convenience Methods
    
//    /// Download and get file URL for sharing
//    func downloadForSharing(request: ExportDetailsRequest, fileName: String = "export_data.csv") async throws -> URL {
//        return try await downloadCSV(
//            request: request,
//            fileName: fileName,
//            saveLocation: .temporary
//        )
//    }
    
    /// Download and immediately present share sheet
//    @MainActor
//    func downloadAndShare(
//        request: ExportDetailsRequest,
//        fileName: String = "export_data.csv"
//    ) async throws {
//        let fileURL = try await downloadForSharing(request: request, fileName: fileName)
//        self.downloadedFileURL = fileURL
//    }
    
    /// Get all downloaded CSV files
    func getDownloadedFiles() -> [URL] {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return []
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            ).filter { $0.pathExtension == "csv" }
            
            // Sort by creation date (newest first)
            return files.sorted {
                let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate
                let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate
                return (date1 ?? Date.distantPast) > (date2 ?? Date.distantPast)
            }
        } catch {
            print("Error getting downloaded files: \(error)")
            return []
        }
    }
    
    /// Delete a downloaded file
    func deleteFile(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    /// Read CSV file content
    func readCSVFile(at url: URL) throws -> String {
        return try String(contentsOf: url, encoding: .utf8)
    }
    
    /// Parse CSV data into structured format
    func parseCSVData(at url: URL) throws -> [[String]] {
        let content = try String(contentsOf: url, encoding: .utf8)
        let rows = content.components(separatedBy: .newlines)
        return rows.map { $0.components(separatedBy: ",") }
    }
}

// MARK: - Save Location Enum
enum SaveLocation {
    case downloads          // App's documents directory (visible in Files app)
    case temporary         // Temporary directory for immediate sharing
    case documentsVisible  // Documents/Downloads folder (visible in Files app)
}

// MARK: - CSV Download Error
enum CSVDownloadError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case fileSystemError
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for download"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .fileSystemError:
            return "Error accessing file system"
        case .parsingError:
            return "Error parsing CSV data"
        }
    }
}
