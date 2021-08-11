//
//  Question.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/11.
//

import Foundation

struct Question: Codable {
    let question: String
    let answer: String
    let answerInKana: String
}
