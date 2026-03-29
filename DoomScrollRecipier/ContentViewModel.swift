//
//  ContentViewModel.swift
//  DoomScrollRecipier
//
//  Created by Pandolfo Diego on 14.01.26.
//

internal import Combine
import Foundation
import FoundationModels
import Observation
import SwiftUI

class ContentViewModel: ObservableObject {
    let session: LanguageModelSession
    let model: SystemLanguageModel

    var exampleModel: LinkSummaryModel

    let videoFileService: VideoFileService
    let transcriptionService: TranscriptionService

    @Published var statusMessage: String
    @Published var summerizedHistory: [LinkSummaryModel]
    @Published var transcript: String = ""

    init() {
        self.exampleModel = LinkSummaryModel(
            title: "Example",
            link: URL(string: "https://www.example.com")!
        )  //! <-means its 100% a valid url you should handle this properly)
        self.summerizedHistory = [exampleModel]

        self.statusMessage = "Thinking..."

        self.videoFileService = VideoFileService()
        self.transcriptionService = TranscriptionService()

        self.transcript = ""

        self.session = LanguageModelSession()
        self.model = SystemLanguageModel.default
    }

    func transcribeFromUrl(_ url: URL) {
        self.statusMessage = "Downloading..."
        self.transcript = ""

        Task { @MainActor in
            do {
                // Download video, extract audio, then transcribe
                self.statusMessage = "Extracting audio..."
                let audioURL = try await videoFileService.process(url: url)
                defer { try? FileManager.default.removeItem(at: audioURL) }

                self.statusMessage = "Transcribing..."
                let text = try await transcriptionService.transcribe(url: audioURL)
                self.transcript = text
                self.statusMessage = "Done."
            } catch {
                self.statusMessage = "Failed: \(error.localizedDescription)"
            }
        }
    }

    func isModelAvailable() -> Bool {
        switch model.availability {
        case .available:
            return true
        case .unavailable(let unavailableReason):
            return false
        }
    }

    func summarize(transcript: String) async throws -> SummaryModel {
        if !isModelAvailable() {
            self.statusMessage = "Model unavailable"
            throw NSError(
                domain: "ContentViewModel",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Language model is unavailable"
                ]
            )
        }

        self.statusMessage = "Summarizing..."

        // Perform the requests directly and return the model
        let summary = try await session.respond(
            to: "summarize this text: \(transcript)"
        )
        let summaryTitle = try await session.respond(
            to: "give this summary a title: \(summary)"
        )

        self.statusMessage = "done."

        return SummaryModel(
            title: summaryTitle.content,
            summary: summary.content
        )
    }

}
