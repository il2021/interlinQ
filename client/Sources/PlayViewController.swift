//
//  PlayViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

class PlayViewController: UIViewController, PlayingDelegate {
    func problemClosed() {
        print("次の問題のリクエスト")
    }
    
    func answering(userName: String) {
        answeringUser = userName
        print("\(answeringUser)が回答中")
        answerButton.isEnabled = false
        stackButtons.isHidden = true
        //TODO:テキスト読み上げ停止
    }

    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var answerButton: UIButton!
    
    var yomiageTimer = Timer()
    var currentCharNum = 0
    var quiz: Quiz!
    var roomId: String!
    var timerPrg:Timer = Timer()
    let userId = UIDevice.current.identifierForVendor!.uuidString
    var answeringUser: String = ""
    @IBOutlet weak var prg: UIProgressView!
    
    @IBOutlet weak var questionSentence: UITextView!
    var webSocketManager = WebSocketManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        prg.progress = 1.0
        
        displaySentence()
               
    }
    
    
    @IBAction func quitButton(_ sender: Any) {
        dismiss(animated: true) { [self] in
            self.webSocketManager.disconnect()
            self.webSocketManager.connect()
        }
    }
    
    @IBAction func tapanswerButton(_ sender: Any) {
    }
    
    
    @IBAction func testSubmitAnswer(_ sender: Any) {
        
        webSocketManager.submitAnswer(userId: userId, roomId: roomId, isCorrect: true)
    }
    
}

//読みあげ機能
extension PlayViewController {
    
    func displaySentence() {
        yomiageTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(showDelayText(time:)), userInfo: quiz.question, repeats: true)
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
}


extension PlayViewController {
    
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
    
    func progress() {
        //タイマーの初期化
        timerPrg.invalidate()
        prg.progress = 1.0
        //バーがだんだん短くなっていくようにTimerでリピートさせる
        timerPrg = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(timerFunc), userInfo: nil, repeats: true)
    }
    
    @IBAction func showIndicator(_ sender: Any) {
        progress()
    }
    
    
    
}
