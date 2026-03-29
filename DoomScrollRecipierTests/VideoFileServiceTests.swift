//
//  VideoFileServiceTests.swift
//  DoomScrollRecipierTests
//

import Testing
import Foundation
import AVFoundation
@testable import DoomScrollRecipier

struct VideoFileServiceTests {

    // MARK: - Helpers

    /// Creates a 1-second silent audio file in the temp directory.
    /// This acts as a stand-in for a real video/audio file so tests run
    /// offline without any network dependency.
    private func makeSilentAudioFile() throws -> URL {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100)!
        buffer.frameLength = 44100 // 1 second of silence

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".caf")
        let file = try AVAudioFile(forWriting: url, settings: format.settings)
        try file.write(from: buffer)
        return url
    }

    // MARK: - Tests

    /// Happy path: a valid audio file URL produces a .m4a output that exists on disk.
    @Test func processLocalFileProducesM4A() async throws {
        let inputURL = try makeSilentAudioFile()
        defer { try? FileManager.default.removeItem(at: inputURL) }

        let service = VideoFileService()
        let outputURL = try await service.process(url: inputURL)
        defer { try? FileManager.default.removeItem(at: outputURL) }

        #expect(FileManager.default.fileExists(atPath: outputURL.path))
        #expect(outputURL.pathExtension == "m4a")
    }

    /// Cleanup: the intermediate downloaded file is removed by the defer in process(url:),
    /// so only the final .m4a should exist after the call returns.
    @Test func processOnlyLeavesM4ABehind() async throws {
        let inputURL = try makeSilentAudioFile()
        defer { try? FileManager.default.removeItem(at: inputURL) }

        let tempsBefore = try FileManager.default.contentsOfDirectory(
            at: FileManager.default.temporaryDirectory,
            includingPropertiesForKeys: nil
        )

        let service = VideoFileService()
        let outputURL = try await service.process(url: inputURL)
        defer { try? FileManager.default.removeItem(at: outputURL) }

        let tempsAfter = try FileManager.default.contentsOfDirectory(
            at: FileManager.default.temporaryDirectory,
            includingPropertiesForKeys: nil
        )

        // Only one new file should have been added (the .m4a), not two (video + audio)
        let newFiles = tempsAfter.filter { !tempsBefore.contains($0) }
        #expect(newFiles.count == 1)
        #expect(newFiles.first?.pathExtension == "m4a")
    }

    /// Error path: an unreachable URL causes process(url:) to throw.
    @Test func processInvalidURLThrows() async {
        let badURL = URL(string: "https://localhost:0/nonexistent.mp4")!
        let service = VideoFileService()

        await #expect(throws: (any Error).self) {
            _ = try await service.process(url: badURL)
        }
    }
}
