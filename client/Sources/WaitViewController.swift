//
//  WaitViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

class WaitViewController: UIViewController, WebSocketDelegate {
    func createRoom() {
    }
    

    @IBOutlet weak var waitingText: UILabel!
    @IBOutlet weak var roomIdText: UILabel!
    var webSocketManager = WebSocketManager.shared
    var viewModel = WaitViewModel()
    var observers: [NSKeyValueObservation] = []
    var roomId = ""
    var memberNames:[String] = []
    
    override func viewDidLoad() {
        webSocketManager.delegate = self
        super.viewDidLoad()
        
        roomIdText.text = webSocketManager.roomId


    }
    
    func ready() {
        self.performSegue(withIdentifier: "toPlay", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlay"{
            let nextVC = segue.destination as! PlayViewController
            
            nextVC.quiz = webSocketManager.quiz
            print(webSocketManager.quiz)
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
