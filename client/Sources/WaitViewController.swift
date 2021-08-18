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
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true) { [self] in
            webSocketManager.disconnect()
            webSocketManager.connect()
        }
    }
    
    
}
