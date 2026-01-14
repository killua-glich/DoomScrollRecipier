//
//  ContentViewModel.swift
//  DoomScrollRecipier
//
//  Created by Pandolfo Diego on 14.01.26.
//

internal import Combine
import Foundation
import Observation
import SwiftUI

class ContentViewModel: ObservableObject {

    var exampleModel: LinkSummaryModel
    
    @Published var statusMessage: String
    @Published var summerizedHistory: [LinkSummaryModel]

    init() {
        self.exampleModel = LinkSummaryModel(
            title: "Example",
            link: URL(string: "https://www.example.com")!
        )  //! <-means its 100% a valid url you should handle this properly)
        self.summerizedHistory = [exampleModel]
        
        self.statusMessage = "Thinking..."
    }

}
