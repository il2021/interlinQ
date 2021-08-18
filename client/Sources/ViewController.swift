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
    
    /*
     ## TIPS
     * hide -> answer -> 各選択肢　（ボタンの押し方）
     ## TODO
     * ひらがなとカタカナごちゃまぜ
     * 数字とか記号とかには対応してない
     * 画面遷移時のイベントはhideボタンで対応
     * 答えるボタンを押すとisHidden=falseをあとに実行しているはずなのに一瞬setTitleされていないボタンが表示されてしまう
     ## PARAM
     * answer: 答え
     * currentCharNum: その時までに表示した文字数
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
    var answer:String = "あいうえお"
    var currentCharNum:Int = 0
    var ansLen:Int = 0
    var answerChoices: [String] = ["", "", "", ""]
    
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var answerButton4: UIButton!
    var ansButtonArray: [UIButton]!
    
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
        var tmp = hira + kata  // 本番は使わない？だろうのでtmp
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
        if (currentCharNum < ansLen){
            var ansChar = strAccess(str: answer, index: currentCharNum)  // 正解の文字
            var ansIndex = Int.random(in: 0 ..< 4)  // 正解が入る場所(1-4)
            answerChoices[ansIndex] = ansChar
            generateChoicesRandomly()
            for i in 0..<4 {
                ansButtonArray[i].setTitle(answerChoices[i], for: .normal)
            }
            currentCharNum += 1
            answerChoices = ["", "", "", ""]
        }else if (currentCharNum == ansLen) {
            hideButton()
        }
    }
    
    @IBAction func answer1(_ sender: Any) {
        displayChoicesRandomly()
    }
    @IBAction func answer2(_ sender: Any) {
        displayChoicesRandomly()
    }
    @IBAction func answer3(_ sender: Any) {
        displayChoicesRandomly()
    }
    @IBAction func answer4(_ sender: Any) {
        displayChoicesRandomly()
    }
    
    @IBAction func go(_ sender: Any) {
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
