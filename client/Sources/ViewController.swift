//
//  ViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/10.
//

/*
 * question: 問題文
 * displaySentence: 問題文を0.3秒間隔で一文字ずつ表示
 * https://tech.naturalmindo.com/idea_ios_text_delay/
 */

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func toTestButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toTest", sender: self)
    }
    
    var timer = Timer()
    var currentCharNum = 0
    var question:String = "Hello, world!"
        
    func displaySentence() {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(showDelayText(time:)), userInfo: question, repeats: true)
    }
        
    @objc func showDelayText(time: Timer) {
        let message = time.userInfo as! String
        questionSentence.text = String(message.prefix(currentCharNum))
        if message.count <= currentCharNum {
            time.invalidate()
            currentCharNum = 0
            return
        }
        currentCharNum += 1
    }
    
    @IBOutlet weak var questionSentence: UITextView!
    
    @IBAction func buttonPressed(_ sender: Any) {
        displaySentence()
    }
}
