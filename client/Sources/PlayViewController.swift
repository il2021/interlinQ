//
//  PlayViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import UIKit

enum inputButton: Int {
    case input0 = 0
    case input1 = 1
    case input2 = 2
    case input3 = 3
}

class PlayViewController: UIViewController, PlayingDelegate {
    func problemAnswered(isCorrect: Bool) {
        print("相手が正解したか\(isCorrect)")
        if isCorrect {
            player2Point += 10
        } else {
            canAnswerState()
            player2Point -= 10
        }

    }
    
    func submitAnswer() {
        print("提出完了")
        answerField.text = ""
        
    }
    
    func canAnswerState() {
        displaying = true
        answerButton.isEnabled = true
        answerButton.backgroundColor = .blue
    }
    
    //他の人が回答中
    func answering(userName: String) {
        answeringUser = userName
        print("\(answeringUser)が回答中")
        answerButton.isEnabled = false
        answerButton.backgroundColor = .gray
        stackButtons.isHidden = true
        //TODO: テキスト読み上げ一時停止
        displaying = false
        
        
    }
    
    func startAnswer() {
        print("自分が回答を始めた ")
        stackButtons.isHidden = false
//        stackButtons.backgroundColor = .blue
        (0..<4).forEach {index in ansButtonArray[index].backgroundColor = .blue}
        answerButton.isEnabled = false
        answerButton.backgroundColor = .gray
        displaying = false
    }
    
    
    func problemClosed() {
        print("次の問題のリクエスト")
        QuizClient.fetchNextQuiz(roomId: roomId) { quiz in
            self.quiz = quiz
            print(quiz)
            print(quiz.answerInKana)
            self.currentCharIndex = 0
            self.currentCharNum = 0
            self.choicedAnswer = ""
            self.updateAnswerField()
            self.nextQuiz()
        }
        
    }
    
    
    func nextQuiz() {
        answerButton.isEnabled = true
        answerButton.backgroundColor = .blue
        stackButtons.isHidden = true
        
        count += 1
        if count < 5 {
            yomiageTimer.invalidate()
            displaySentence()
            // TODO: 新しい問題用にボタンを更新
        } else {
            gameover()
        }
    }
    
    func gameover() {
        self.performSegue(withIdentifier: "toResult", sender: self)
    }
    

    
    @IBOutlet weak var answerField: UILabel!
    
    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var answerButton: UIButton!
    
    @IBOutlet var ansButtonArray: [UIButton]!
    
    //選んだ文字
    var choicedAnswer: String = ""
    var count = 0
    var player2Point = 0
    var currentCharIndex:Int = 0
    var ansLen:Int = 0
    var answerChoices: [String] = ["", "", "", ""]
    
    //読み上げの文字列
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
    var displaying: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webSocketManager.playingdelegate = self
        prg.progress = 1.0
        displaySentence()
        setAnswerChoices()
        settingButton(setStrings: answerChoices)
    }
    
    @IBAction func tapanswerButton(_ sender: Any) {
        print("回答")
        print(quiz.answerInKana)
        webSocketManager.startAnswer(userId: userId, roomId: roomId)
        
    }
    
    func setAnswerChoices() {
        answerChoices = ["", "", "", ""]
        let ansChar = strAccess(str: quiz.answerInKana!, index: currentCharIndex)// 正解の文字
        // 正解が入る場所(1-4)のどれか
        answerChoices[Int.random(in: 0 ..< 4)] = ansChar
        //ランダムな文字
        for i in 0..<4 {
            while (answerChoices[i] == "") {
                answerChoices[i] = generateRandomChar(chartype: ansChar)
            }
        }
        
    }
    
    func settingButton(setStrings: [String]) {
        for i in 0..<4 {
            DispatchQueue.main.async {
                self.ansButtonArray[i].setTitle(setStrings[i], for: .normal)
            }
        }
    }
    
    
    @IBAction func quitButton(_ sender: Any) {
        dismiss(animated: true) { [self] in
            self.webSocketManager.disconnect()
            self.webSocketManager.connect()
        }
    }
    
    
    
    @IBAction func testSubmitAnswer(_ sender: Any) {
        if roomId == "" { fatalError() }
        webSocketManager.submitAnswer(userId: userId, roomId: roomId, isCorrect: true)
    }
    
    
    @IBAction func inputButtonAction(_ sender: Any) {
        if let button = sender as? UIButton {
            if let tag = inputButton(rawValue: button.tag) {
                
                switch tag {
                case .input0:
                    print("input0")
                    choicedAnswer += answerChoices[0]
                    updateAnswerField()
                    judgeAnswer(answerChoices[0], answerChar: strAccess(str: quiz.answerInKana!, index: currentCharIndex))
                   
                case .input1:
                    print("input1")
                    choicedAnswer += answerChoices[1]
                    updateAnswerField()
                    judgeAnswer(answerChoices[1], answerChar: strAccess(str: quiz.answerInKana!, index: currentCharIndex))
                   
                case .input2:
                    print("input2")
                    choicedAnswer += answerChoices[2]
                    updateAnswerField()
                    judgeAnswer(answerChoices[2], answerChar: strAccess(str: quiz.answerInKana!, index: currentCharIndex))
           
                case .input3:
                    print("input3")
                    choicedAnswer += answerChoices[3]
                    updateAnswerField()
                    judgeAnswer(answerChoices[3], answerChar: strAccess(str: quiz.answerInKana!, index: currentCharIndex))
 
                }
                
                
            }
        }
    }
    
    //画面遷移時or問題が切り替わった時に実行
//    func setUpQuiz() {
//        if let answer = quiz.answerInKana {
//            ansLen = answer.count
//        } else {
//            print("クイズなし")
//        }
//    }
    
    func judgeAnswer(_ userinputChar: String, answerChar: String) {
        if choicedAnswer == quiz.answerInKana! {
            print("正解")
            webSocketManager.submitAnswer(userId: userId, roomId: roomId, isCorrect: true)
            //問題に正解シグナル
        } else if userinputChar == answerChar {
            currentCharIndex += 1
            setAnswerChoices()
            settingButton(setStrings: answerChoices)
            progress()
            
            
        } else {
            print("不正解")
            //失敗シグナル
            webSocketManager.submitAnswer(userId: userId, roomId: roomId, isCorrect: false)
        }
        
        //ユーザーの入力が合っているかどうか
        
    }
    
}


extension PlayViewController {
    
    func updateAnswerField() {
        DispatchQueue.main.async {
            self.answerField.text = self.choicedAnswer
        }
        
    }
    
    // 文字列で返す。
    func strAccess(str: String, index: Int) -> String {
        let char = String(str[str.index(str.startIndex, offsetBy: index)..<str.index(str.startIndex, offsetBy: index+1)])
        return char
    }
    
    
    func generateRandomChar(chartype: String) -> String {
        
        let hira:String = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
        let kata:String = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
        let alpha:String = "abcdefghijklmnopqrstuvwxyz"
        let num:String = "0123456789"
        
        var tmp = ""  // 答えの文字の種類の要素一覧
        if (hira.contains(chartype)) {
            tmp = hira
        } else if (kata.contains(chartype)) {
            tmp = kata
        } else if (alpha.contains(chartype)) {
            tmp = alpha
        } else {
            tmp = num
        }

        return strAccess(str: tmp, index: Int.random(in: 0 ..< tmp.count))
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
            return
        }
        if (displaying) {
            currentCharNum += 1
        }
    }
    
}

//残り時間機能
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
