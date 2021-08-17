//
//  APIRepository.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/17.
//

import Combine
import Foundation
import UIKit
import Alamofire

class QuizClient {
    
    static func fetchNextQuiz(roomId: String, completion: @escaping (Quiz) -> Void) {
        var quiz: Quiz = Quiz(id: "f", available: true, question: "", answer: "f", answerInKana: "f")
        let request = AF.request(QuizRepository.nextQURL.queryItemAdded(name: "roomId", value: roomId)!.absoluteString)
        request.responseJSON { response in
            //            debugPrint(response)
            let decoder: JSONDecoder = JSONDecoder()
            
            if let data = response.data {
                do {
                    quiz = try decoder.decode(Quiz.self, from: data)
                    
                } catch {
                    print("failed")
                }
            } else {
                print("データ未取得")
            }
            
            completion(quiz)
            
        }
        
    }
    
}

class QuizRepository {
    static let nextQURL = URL(string: "http://localhost:8080/api/problems/next")!
}
extension URL {
    /// クエリを一つ追加した新しいURLを返す
    func queryItemAdded(name: String, value: String?) -> URL? {
        return self.queryItemsAdded([URLQueryItem(name: name, value: value)])
    }
    
    /// クエリを複数追加した新しいURLを返す.
    /// [URLQueryItem]は自分で定義
    func queryItemsAdded(_ queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: nil != self.baseURL) else {
            return nil
        }
        components.queryItems = queryItems + (components.queryItems ?? [])
        return components.url
    }
    
}
//
//class APIClient {
//    var quiz: Quiz? = nil
//    var quizes: [Quiz] = []
//    func request() {
//        let request = AF.request("http://localhost:8080/api/problems/random")
//        request.responseJSON { response in
//            let decoder: JSONDecoder = JSONDecoder()
//            if let data = response.data {
//                do {
//                    self.quizes = try decoder.decode([Quiz].self, from: data)
//                    print(self.quizes)
//                } catch {
//                    print("failed")
//                }
//            } else {
//                print("データ未取得")
//            }
//
//        }
//    }
//
//
//}
