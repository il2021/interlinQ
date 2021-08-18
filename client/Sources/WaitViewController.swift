//
//  WaitViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

class WaitViewController: UIViewController {
    
    @IBOutlet weak var waitingText: UILabel!
    var webSocketManager = WebSocketManager.shared
    var viewModel = WaitViewModel()
    var observers: [NSKeyValueObservation] = []
    var roomId = ""
    var memberNames:[String] = []
    
    override func viewDidLoad() {
       
        super.viewDidLoad()

        let observer2 = viewModel.observe(\.canStart) { [weak self] (viewModel, _) in
            if viewModel.canStart {
                print("画面遷移")
            }
            
        }
        
        // MARK: 部屋の準備が整った時
        webSocketManager.socket.on("room-ready"){ [self] data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {
                    self.roomId = roomId
                }
                
                if let memberNames = arr[0]["memberNames"] as? [String] {
                    self.memberNames = memberNames
                }
                
                
            }
        
            self.performSegue(withIdentifier: "toPlay", sender: self)
            
            print("roomId:\(self.roomId)")
            print("room-ready:2人集まった \(self.memberNames)")
            QuizClient.fetchNextQuiz(roomId: roomId) { quiz in
                webSocketManager.quiz = quiz
            }
        }

        
        
        observers = [observer2]

    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true) {
            self.viewModel.buttonPressed()
        }
    }
    
    
}



class WaitViewModel: NSObject {
    var webSocketManager = WebSocketManager.shared
    
    @objc dynamic var canStart: Bool {
        get {
            return webSocketManager.canStart
        }
    }
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
