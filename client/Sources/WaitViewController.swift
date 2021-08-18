//
//  WaitViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

class WaitViewController: UIViewController, WebSocketDelegate {

    
    func connect() {
    }
    
    func createRoom(_ roomId: String) {
    }
    


    @IBOutlet weak var waitingText: UILabel!
    @IBOutlet weak var roomIdText: UILabel!
    var webSocketManager = WebSocketManager.shared
    var viewModel = WaitViewModel()
    var observers: [NSKeyValueObservation] = []
    var roomId: String!
    var memberNames:[String] = []
    var quiz: Quiz!
    override func viewDidLoad() {
        webSocketManager.delegate = self
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.roomIdText.text = self.roomId
        }
       

    }
    
    func ready(_ quiz: Quiz, roomId: String) {
        QuizClient.fetchNextQuiz(roomId: roomId) { quiz in
            self.quiz = quiz
            print(quiz.question)
            assert(quiz.available != nil)
            self.performSegue(withIdentifier: "toPlay", sender: self)
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlay"{
            let nextVC = segue.destination as! PlayViewController
            
            nextVC.quiz = quiz
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true) {
            self.viewModel.buttonPressed()
        }
    }
    
    
}




class WaitViewModel: NSObject {
    var webSocketManager = WebSocketManager.shared
    func buttonPressed() {
        webSocketManager.disconnect()
        webSocketManager.connect()
    }
    
    
}
