//
//  ViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/10.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func toTestButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toTest", sender: self)
    }
}
