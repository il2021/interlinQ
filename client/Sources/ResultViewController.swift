//
//  ResultViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var loseLabel: UILabel!
    var player1Point = 0
    var player2Point = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func returnHomeButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toHome", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHome"{
            let nextVC = segue.destination as! HomeViewController
                
            // close-room で部屋を削除
        }
    }
}
