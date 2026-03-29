//
//  TranscriptionServiceTests.swift
//  DoomScrollRecipierTests
//
//  SETUP REQUIRED:
//  1. Make sure test_speech.m4a is added to the DoomScrollRecipierTests target
//  2. Grant speech recognition permission when prompted on first run
//  3. Update expectedPhrase in transcribedTextContainsExpectedPhrase() to match your recording
//

import Testing
import Foundation
import Speech
@testable import DoomScrollRecipier

// A concrete class anchors Bundle lookup to the test target's bundle.
// This is the standard pattern since Swift Testing uses structs (not classes).
private class BundleLocator {}

struct TranscriptionServiceTests {

    // MARK: - Helpers

    private var testBundle: Bundle {
        Bundle(for: BundleLocator.self)
    }

    /// Returns the URL of the bundled test audio file.
    /// Tries both the bundle root (Xcode group/yellow folder) and the
    /// testAssets subdirectory (Xcode folder reference/blue folder).
    private func testAudioURL() throws -> URL {
        let url = testBundle.url(forResource: "test_speech", withExtension: "m4a")
               ?? testBundle.url(forResource: "test_speech", withExtension: "m4a", subdirectory: "testAssets")
        guard let url else {
            throw SetupError.missingResource(
                "test_speech.m4a not found in DoomScrollRecipierTests bundle. " +
                "Select the file in Xcode and make sure its target membership includes DoomScrollRecipierTests."
            )
        }
        return url
    }

    enum SetupError: Error, CustomStringConvertible {
        case missingResource(String)
        var description: String {
            switch self { case .missingResource(let msg): msg }
        }
    }

    // MARK: - Tests

    /// Verifies that transcribing the bundled audio file returns a non-empty string.
    /// This is the basic smoke test — it passes as long as something was recognized.
    @Test @MainActor func transcribesBundledAudioToNonEmptyString() async throws {
        let service = TranscriptionService()
        try await service.requestSpeechAuth()

        let result = try await service.transcribe(url: testAudioURL())

        #expect(!result.isEmpty)
    }

    /// Verifies the transcript contains the phrase spoken in the test audio.
    /// Update expectedPhrase to match what you said in test_speech.m4a.
    @Test @MainActor func transcribedTextContainsExpectedPhrase() async throws {
        let expectedPhrase = "Test, test, hello world, test, test." // ← update to match your recording

        let service = TranscriptionService()
        try await service.requestSpeechAuth()

        let result = try await service.transcribe(url: testAudioURL())

        #expect(result.localizedCaseInsensitiveContains(expectedPhrase),
                "Got: \"\(result)\"")
    }
}
