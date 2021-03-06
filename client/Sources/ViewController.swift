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

import AVFoundation

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
            // TODO: WebSocketのsubmit-answer
        } else {
               prg.setProgress(newValue, animated: true)
        }
    }
       
    @IBAction func showIndicator(_ sender: Any) {
        progress()
    }
    
    //sound effect

    var player:AVAudioPlayer?
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

    @IBAction func buzzer(_ sender: Any) {
        // 再生する音声ファイルを指定する
        let soundURL = Bundle.main.url(forResource: "Buzzer", withExtension: "mp3")
        do {
            // 効果音を鳴らす
            player = try AVAudioPlayer(contentsOf: soundURL!)
            player?.play()
        } catch {
            print("error...")
        }
    }

    @IBAction func correctAnswer(_ sender: Any) {
        let soundURL = Bundle.main.url(forResource: "Correct_Answer", withExtension: "mp3")
        do {
            // 効果音を鳴らす
            player = try AVAudioPlayer(contentsOf: soundURL!)
            player?.play()
        } catch {
            print("error...")
        }
    }
    
    @IBAction func question(_ sender: Any) {
        let soundURL = Bundle.main.url(forResource: "Question", withExtension: "mp3")
        do {
            // 効果音を鳴らす
            player = try AVAudioPlayer(contentsOf: soundURL!)
            player?.play()
        } catch {
            print("error...")
        }
    }
    
    @IBAction func wrongAnswer(_ sender: Any) {
        let soundURL = Bundle.main.url(forResource: "Wrong_Answer", withExtension: "mp3")
        do {
            // 効果音を鳴らす
            player = try AVAudioPlayer(contentsOf: soundURL!)
            player?.play()
        } catch {
            print("error...")
        }
    }
    
    //display sentence
    
    @IBAction func toTestButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toTest", sender: self)
    }
    
    var timer = Timer()
    var currentCharNum = 0
    var question:String = "Hello, world!"
    var displaying:Bool = true
    var buttonFlag:Bool = true  // 問題切り替わるたびにtrueにする
        
    func displaySentence(interval: Double=0.3) {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(showDelayText(time:)), userInfo: question, repeats: true)
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
    
    @IBOutlet weak var questionSentence: UITextView!
    
    @IBAction func buttonPressed(_ sender: Any) {
        if (buttonFlag) {
            currentCharNum = 0
            displaySentence()
            buttonFlag = false
        }
    }
    
    /*
     ## TIPS
     * hide -> answer -> 各選択肢　（ボタンの押し方）
     ## TODO
     * 記号には対応してない
     * 画面遷移時のイベントはhideボタンで対応
     * 答えるボタンを押すとisHidden=falseをあとに実行しているはずなのに一瞬setTitleされていないボタンが表示されてしまう
     ## PARAM
     * answer: 答え
     * ancChar: 正解の文字
     * currentCharIndex: その時までに表示した文字数
     * ansLen: 答えの文字列の長さ
     * answerChoices: 答えの選択肢
     * ansButtonArray: 選択肢のボタンが入った配列
     ## FUNC
     * strAccess: strのindex番目の文字を返す
     * generateChoicesRandomly: 選択肢をランダムに生成
     * displayChoicesRandomly: 選択肢をランダムに表示
     * hideButton: ボタンを隠す（画面遷移時に実行）
     */
    var hira:String = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
    var kata:String = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
    var alpha:String = "abcdefghijklmnopqrstuvwxyz"
    var num:String = "0123456789"
    var answer:String = "あいうエオカabc123" //quizhira
    var ansChar = ""
    var currentCharIndex:Int = 0
    var ansLen:Int = 0
    var answerChoices: [String] = ["", "", "", ""]
    var choicedAnswer: String = ""
    
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var answerButton4: UIButton!
    var ansButtonArray: [UIButton]!
    
    @IBOutlet weak var answerField: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ansLen = answer.count
    }
    
    func strAccess(str: String, index: Int) -> String {
        var char = String(str[str.index(str.startIndex, offsetBy: index)..<str.index(str.startIndex, offsetBy: index+1)])
        return char
    }
    
    func hideButton() {
        answerButton1.isHidden = true
        answerButton2.isHidden = true
        answerButton3.isHidden = true
        answerButton4.isHidden = true
    }
    
    func generateChoicesRandomly() {
        var tmp = ""  // 答えの文字の種類の要素一覧
        if (hira.contains(ansChar)) {
            tmp = hira
        } else if (kata.contains(ansChar)) {
            tmp = kata
        } else if (alpha.contains(ansChar)) {
            tmp = alpha
        } else {
            tmp = num
        }
        var tmpLen = tmp.count
        
        for i in 0..<4 {
            while (answerChoices[i] == "") {
                var index = Int.random(in: 0 ..< tmpLen)
                var choice = strAccess(str: tmp, index: index)
                if (!answerChoices.contains(choice)){
                    answerChoices[i] = choice
                }
            }
        }
    }
    
    func displayChoicesRandomly() {
        if (currentCharIndex < ansLen){
            ansChar = strAccess(str: answer, index: currentCharIndex)  // 正解の文字
            var ansIndex = Int.random(in: 0 ..< 4)  // 正解が入る場所(1-4)
            answerChoices[ansIndex] = ansChar
            generateChoicesRandomly()
            for i in 0..<4 {
                ansButtonArray[i].setTitle(answerChoices[i], for: .normal)
            }
            currentCharIndex += 1
        }else if (currentCharIndex == ansLen) {
            hideButton()
        }
    }
    
    func updateAnswerField() {
        answerField.text = choicedAnswer
        answerChoices = ["", "", "", ""]
    }
    
    @IBAction func answer1(_ sender: Any) {
        choicedAnswer += answerChoices[0]
        updateAnswerField()
        displayChoicesRandomly()
    }
    @IBAction func answer2(_ sender: Any) {
        choicedAnswer += answerChoices[1]
        updateAnswerField()
        displayChoicesRandomly()
    }
    @IBAction func answer3(_ sender: Any) {
        choicedAnswer += answerChoices[2]
        updateAnswerField()
        displayChoicesRandomly()
    }
    @IBAction func answer4(_ sender: Any) {
        choicedAnswer += answerChoices[3]
        updateAnswerField()
        displayChoicesRandomly()
    }
    
    @IBAction func go(_ sender: Any) {
        displaying = false
        displayChoicesRandomly()
        answerButton1.isHidden = false
        answerButton2.isHidden = false
        answerButton3.isHidden = false
        answerButton4.isHidden = false
    }
    // 画面遷移時or問題が切り替わった時に実行
    @IBAction func hide(_ sender: Any) {
        ansButtonArray = [answerButton1, answerButton2, answerButton3, answerButton4]  // コンストラクタにはいれられない
        hideButton()
    }
}
