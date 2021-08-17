//
//  HomeViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/17.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func tapGoButton(_ sender: Any) {
        
    }
    

struct StartAnswer: SocketData {
    let userId: String
    let roomId: String
    
    func socketRepresentation() -> SocketData {
        return ["userId": userId, "roomId": roomId]
    }
}

struct Answer: SocketData {
    let userId: String
    let roomId: String
    let isCorrect: Bool
    func socketRepresentation() -> SocketData {
        return ["userId": userId, "roomId": roomId, "isCorrect": isCorrect]
    }
}
