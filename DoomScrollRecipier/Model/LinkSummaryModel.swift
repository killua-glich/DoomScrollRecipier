//
//  LinkSummaryModel.swift
//  DoomScrollRecipier
//
//  Created by Pandolfo Diego on 14.01.26.
//

import Foundation

struct LinkSummaryModel: Codable{
    var title: String
    var link: URL
    
    var transcription: String?
    //Maybe Link To File???
}
