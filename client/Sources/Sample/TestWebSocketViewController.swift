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
    var questions: [Question] = []
    var dataList :NSMutableArray! = []
    var apiClient = APIClient()
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
        
        
        socket.on("responseQuestion") {data, ack in
            if let message = data as? [String] {
                print(message[0])
            }
        }
        
        socket.connect()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        socket.disconnect()
    }
    @IBAction func tapButtonAction(_ sender: Any) {

        socket.emit("getQuestion")
        
    }
    
    @IBAction func connectButtonAction(_ sender: Any) {
        socket.connect()
        
        
    }
    @IBAction func disconnectButtonAction(_ sender: Any) {
        socket.disconnect()
    }
    
    @IBAction func getRandomQuestion(_ sender: Any) {
        apiClient.request()
    }
}

class APIClient {
    var questions: [Question] = []
    
    func request() {
        let request = AF.request("http://localhost:8080/api/problems/random")
        request.responseJSON { response in
            let decoder: JSONDecoder = JSONDecoder()
            do {
                self.questions = try decoder.decode([Question].self, from: response.data!)
                print(self.questions)
            } catch {
                print("failed")
            }
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
