//
//  PlayViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

class PlayViewController: UIViewController {
    var quiz: Quiz!
    @IBOutlet weak var quizDiscription: UITextView!
    var webSocketManager = WebSocketManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.quizDiscription.text = self.quiz.question
        }
        
       
    }
    
    @IBAction func quitButton(_ sender: Any) {
        dismiss(animated: true) { [self] in
            self.webSocketManager.disconnect()
            self.webSocketManager.connect()
        }
    }
    

}

