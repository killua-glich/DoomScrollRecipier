//
//  VideoFileService.swift
//  DoomScrollRecipier
//
//  Created by diego on 14.01.26.
//

import Foundation
import AVFoundation


class VideoFileService {
    func downloadTempFile(from url: URL) async throws -> URL {
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        let filename = UUID().uuidString + "." + url.pathExtension
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: tempURL, to: destination)
        
        return destination
    }
    
    func extractAudio(from videoURL: URL) async throws -> URL {
        let asset = AVURLAsset(url: videoURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(domain: "ExportError", code: -1)
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        
        try await exportSession.export()
        
        return outputURL
    }
}

