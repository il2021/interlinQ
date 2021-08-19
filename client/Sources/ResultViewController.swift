//
//  ResultViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var judgeLabel: UILabel!
    var player1Point: Int!
    var player2Point: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        judgeLabel.font = UIFont.systemFont(ofSize: 50)
        judge()
    }
    
    func judge() {

        if player1Point > player2Point {
            judgeLabel.text = "You WIN!!!"
        } else if player1Point == player2Point {
            
            judgeLabel.text = "Draw"
        } else {
            
            judgeLabel.text = "You LOSE..."
        }
        
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
