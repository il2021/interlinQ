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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let observer2 = viewModel.observe(\.canStart) { [weak self] (viewModel, _) in
            if viewModel.canStart {
                print("画面遷移")
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
