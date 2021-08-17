//
//  TestWebSocketViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/11.
//

import UIKit
import SocketIO
import Alamofire

class TestWebSocketViewController: UIViewController {

    let manager = SocketManager(socketURL: URL(string:"http://localhost:8080/")!, config: [.log(true), .compress])
    var socket : SocketIOClient!
    #if DEBUG
    var roomId = "test"
    #endif
    let userId = UIDevice.current.identifierForVendor!
    @IBOutlet weak var logConsoleField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { data, ack in
            //ack:確認応答フラグ
            print("socket connected.\ndata: \(data)\n\(ack)")
        }
        socket.on(clientEvent: .disconnect){data, ack in
            print("socket disconnected!")
        }
        
        socket.on("from_server"){ data, ack in
            if let message = data as? [String] {
                print(message[0])
                
            }
        }
        
        
        // MARK: 部屋の準備が整った時
        socket.on("room-ready"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {

                    self.roomId = roomId
                }
            }
            
            // 次の画面にPush

            
            
        }
        
        socket.on("room-created"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {
                    print("あなたのroomId: \(roomId)")
                    self.roomId = roomId
                }
            }
        }
        
        socket.connect()
        
    }
    
    func log() {
        DispatchQueue.main.async {
            self.logConsoleField.text = ""
            self.logConsoleField.text += self.userId.uuidString + "\n"
            self.logConsoleField.text += self.roomId
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        socket.disconnect()
    }
    @IBAction func tapButtonAction(_ sender: Any) {
        
        socket.emit("join-room", userId.uuidString) {
            print("送信完了")
        }
        log()
        
    }
    
    @IBAction func connectButtonAction(_ sender: Any) {
        socket.connect()
        
    }
    @IBAction func disconnectButtonAction(_ sender: Any) {
        socket.disconnect()
    }
    @IBAction func tapGetQuizButton(_ sender: Any) {
        QuizClient.fetchNextQuiz(roomId: roomId) {  quiz in
            print(quiz ?? "値なし")
            
        }
        
        
    }
    
    
}


struct CustomData : SocketData {
    let name: String
    let age: Int
    
    func socketRepresentation() -> SocketData {
        return ["name": name, "age": age]
    }
}
