//
//  Quiz.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/17.
//

import Foundation

struct Quiz: Codable {
    let id: String?
    let available: Bool?
    let question: String?
    let answer: String?
    let answerInKana: String?
}
