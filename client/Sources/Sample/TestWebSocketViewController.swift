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
    var dataList :NSMutableArray! = []
    var apiClient = APIClient()
    var roomId = ""
    let userId = UIDevice.current.identifierForVendor!
    var roomReady = false
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
                self.dataList.insert(message[0],at: 0)
                
            }
        }
        
        
        // MARK: roomIdはまだ、変化する。
        socket.on("room-ready"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {
                    print("あなたのroomId: \(roomId)")
                    self.roomId = roomId
                }
            }
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
        print(roomId)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        socket.disconnect()
    }
    @IBAction func tapButtonAction(_ sender: Any) {
        
        socket.emit("join-room", "testid") {
            print("送信完了")
        }
    }
    
    @IBAction func connectButtonAction(_ sender: Any) {
        socket.connect()
        
    }
    @IBAction func disconnectButtonAction(_ sender: Any) {
        socket.disconnect()
    }
    @IBAction func tapGetQuestionButton(_ sender: Any) {
        apiClient.request()
    }
}

class APIClient {
    var questions: [Question] = []
    
    func request() {
        let request = AF.request("http://localhost:8080/api/problems/random")
        request.responseJSON { response in
            let decoder: JSONDecoder = JSONDecoder()
            if let data = response.data {
                do {
                    self.questions = try decoder.decode([Question].self, from: data)
                    print(self.questions)
                } catch {
                    print("failed")
                }
            } else {
                print("データ未取得")
            }
            
        }
        
        
        
    }
}

struct Question: Codable {
    let question: String
    let answer: String
    let answerInKana: String
}

struct CustomData : SocketData {
    let name: String
    let age: Int
    
    func socketRepresentation() -> SocketData {
        return ["name": name, "age": age]
    }
}
