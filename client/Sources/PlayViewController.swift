//
//  PlayViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

class PlayViewController: UIViewController {
    var viewModel = PlayViewModel()
    @IBOutlet weak var quizDiscription: UITextView!
    var webSocketManager = WebSocketManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quizDiscription.text = webSocketManager.quiz.question
       
    }
    
    @IBAction func quitButton(_ sender: Any) {
        dismiss(animated: true) {
            self.viewModel.buttonPressed()
        }
    }
    

}


class PlayViewModel: NSObject {
    var webSocketManager = WebSocketManager.shared
    
    @objc dynamic private(set) var buttonIsEnabled: Bool = false
    @objc dynamic private(set) var isLoading: Bool = false
    @objc dynamic private(set) var waiting: Bool = false
    
    var observers: [NSKeyValueObservation] = []
    let userId = UIDevice.current.identifierForVendor!
    
    
    func buttonPressed() {
        webSocketManager.disconnect()
        webSocketManager.connect()
    }
    
    
}
