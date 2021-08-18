//
//  HomeViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/17.
//

import UIKit

class HomeViewController: UIViewController, WebSocketDelegate {
    
    func connect() {
        DispatchQueue.main.async {
            self.ActivityIndicator.startAnimating()
        }
        
    }
    

    var quiz: Quiz = Quiz(id: nil, available: nil, question: nil, answer: nil, answerInKana: nil)
    
    var roomId = ""
    
    var ActivityIndicator: UIActivityIndicatorView!
    let viewModel = HomeViewModel()
    var webSocketManager = WebSocketManager.shared
    @IBOutlet weak var searchingText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webSocketManager.delegate = self
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center
        
        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true
        
        // 色を設定
        ActivityIndicator.style = .medium
        
        //Viewに追加
        self.view.addSubview(ActivityIndicator)

       
    }
    
    func ready(_ quiz: Quiz, roomId: String) {
        self.quiz = quiz
        self.performSegue(withIdentifier: "fromHometoPlay", sender: self)
    }
    
    func createRoom(_ roomId: String) {
        self.roomId = roomId
        self.performSegue(withIdentifier: "toWait", sender: self)
    }
    
    @IBAction func tapGoButton(_ sender: Any) {
        ActivityIndicator.stopAnimating()
        viewModel.buttonPressed()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWait"{
            let nextVC = segue.destination as! WaitViewController
            
            nextVC.roomId = self.roomId
        }
        
        if segue.identifier == "fromHometoPlay"{
            let nextVC = segue.destination as! PlayViewController
            nextVC.roomId = self.roomId
            nextVC.quiz = self.quiz
        }
    }
    
}

class HomeViewModel: NSObject {

    @objc dynamic private(set) var buttonIsEnabled: Bool = false
    @objc dynamic private(set) var isLoading: Bool = false
    @objc dynamic private(set) var waiting: Bool = false
    
    var observers: [NSKeyValueObservation] = []
    let userId = UIDevice.current.identifierForVendor!
    
    var webSocketManager: WebSocketManager = WebSocketManager.shared

    func buttonPressed() {
        print("ユーザーID:\(userId)")
        webSocketManager.connect()
        webSocketManager.joinRoom(userId: userId, userName: "テストユーザー")
        isLoading = webSocketManager.isConnect
        waiting = webSocketManager.isWaiting

    }
    
    
}
