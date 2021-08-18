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
    
    //indicator
    
    @IBOutlet weak var prg: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prg.progress = 1.0
    }
    
    var timerPrg:Timer = Timer()
    
    func progress() {
        prg.progress = 1.0
        //バーがだんだん短くなっていくようにTimerでリピートさせる
        timerPrg = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(timerFunc), userInfo: nil, repeats: true)
    }
    //タイマーの中身
    @objc func timerFunc() {
           // prgの現在の数値より少しだけ少ない数値をprgにセット
        let newValue = prg.progress - 0.01
           // 10秒ぐらいで0になりますので
        if (newValue < 0) {
               // newValueが０より小さくなってしまったら
               prg.setProgress(0, animated: true)
               // タイマーを停止させます
               timerPrg.invalidate()
        } else {
               prg.setProgress(newValue, animated: true)
        }
    }
       
    @IBAction func showIndicator(_ sender: Any) {
        progress()
    }
       

    //display sentence
    
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
