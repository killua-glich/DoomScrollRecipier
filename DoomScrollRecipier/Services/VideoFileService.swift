//
//  VideoFileService.swift
//  DoomScrollRecipier
//
//  Created by diego on 14.01.26.
//

import Foundation
import AVFoundation


class VideoFileService {

    // Downloads a remote URL to a stable local temp file
    private func downloadTempFile(from url: URL) async throws -> URL {
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        let filename = UUID().uuidString + "." + url.pathExtension
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: tempURL, to: destination)
        
        return destination
    }
    
    // Extracts audio track from a local video file and writes it as .m4a
    private func extractAudio(from videoURL: URL) async throws -> URL {
        let asset = AVURLAsset(url: videoURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(domain: "ExportError", code: -1)
        }
        
        // export(to:as:) is the non-deprecated API in iOS 18+
        try await exportSession.export(to: outputURL, as: .m4a)
        
        return outputURL
    }

    // Full pipeline: remote URL → local video → local audio file ready for transcription
    func process(url: URL) async throws -> URL {
        let videoURL = try await downloadTempFile(from: url)
        defer { try? FileManager.default.removeItem(at: videoURL) }
        return try await extractAudio(from: videoURL)
    }
}

