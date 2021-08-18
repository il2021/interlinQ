//
//  HomeViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/17.
//

import UIKit

class HomeViewController: UIViewController {
    var ActivityIndicator: UIActivityIndicatorView!
    let viewModel = HomeViewModel()
    var observers: [NSKeyValueObservation] = []
    @IBOutlet weak var searchingText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchingText.text = ""
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center
        
        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true
        
        // 色を設定
        ActivityIndicator.style = .medium
        
        //Viewに追加
        self.view.addSubview(ActivityIndicator)
    
        let observer1 = viewModel.observe(\.labelText) { [weak self] (viewModel, _) in
            self?.searchingText.text = viewModel.labelText
        }
        
        let observer2 = viewModel.observe(\.waiting) { [weak self] (viewModel, _) in
            if viewModel.waiting {
                self?.performSegue(withIdentifier: "toWait", sender: self)
            }
            
        }
        
        
        observers = [observer1, observer2]
    }
    
    
    @IBAction func tapGoButton(_ sender: Any) {
        viewModel.isLoading ? ActivityIndicator.startAnimating() : ActivityIndicator.stopAnimating()
        viewModel.buttonPressed()
    }
    
}

class HomeViewModel: NSObject {
    @objc dynamic private(set) var labelText: String?
    @objc dynamic private(set) var buttonIsEnabled: Bool = false
    @objc dynamic private(set) var isLoading: Bool = false
    @objc dynamic private(set) var waiting: Bool = false
    
    var observers: [NSKeyValueObservation] = []
    let userId = UIDevice.current.identifierForVendor!
    
    var webSocketManager: WebSocketManager = WebSocketManager.shared

    func buttonPressed() {
        labelText = "検索中"
        print("ユーザーID:\(userId)")
        webSocketManager.connect()
        webSocketManager.joinRoom(userId: userId, userName: "テストユーザー")
        isLoading = webSocketManager.isConnect
        waiting = webSocketManager.isWaiting
    }
    
    
}
