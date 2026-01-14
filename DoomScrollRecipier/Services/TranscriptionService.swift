//
//  TranscriptionService.swift
//  DoomScrollRecipier
//
//  Created by diego on 18.01.26.
//

import Foundation
import Speech

class TranscriptionService {

    enum TranscriptionError: Error {
        case notAuthorized
        case recognizerUnavailable
        case noResult
    }

    func requestSpeechAuth() async throws {
        let status = SFSpeechRecognizer.authorizationStatus()
        if status == .authorized { return }

        let newStatus = await withCheckedContinuation { (continuation: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        guard newStatus == .authorized else {
            throw TranscriptionError.notAuthorized
        }
    }

    func transcribe(url: URL) async throws -> String {
        // Use the device's current locale; you can inject a specific one if needed
        guard let recognizer = SFSpeechRecognizer(locale: Locale.current), recognizer.isAvailable else {
            throw TranscriptionError.recognizerUnavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = false
        request.shouldReportPartialResults = false

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            var task: SFSpeechRecognitionTask?

            task = recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    task?.cancel()
                    continuation.resume(throwing: error)
                    return
                }

                if let result = result, result.isFinal {
                    task?.cancel()
                    continuation.resume(returning: result.bestTranscription.formattedString)
                    return
                }
            }
        }
    }
}
