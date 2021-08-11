//
//  TestWebSocketViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/11.
//

import UIKit
import SocketIO
class TestWebSocketViewController: UIViewController {

    let manager = SocketManager(socketURL: URL(string:"http://localhost:8080/")!, config: [.log(true), .compress])
    var socket : SocketIOClient!
    var dataList :NSMutableArray! = []
    
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
        
//        socket.on("from_server"){ data, ack in
//            if let message = data as? [String] {
//                print(message[0])
//                self.dataList.insert(message[0],at: 0)
//
//            }
//        }
        
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
//        socket.emit("from_client", CustomData(name: "Erik", age: 24)) {
//            print("送信完了")
//        }
        socket.emit("getQuestion")
        
    }
    
    @IBAction func connectButtonAction(_ sender: Any) {
        socket.connect()
        getRandomQuestion()
        
    }
    @IBAction func disconnectButtonAction(_ sender: Any) {
        socket.disconnect()
    }
    
}

func getRandomQuestion() {
    let url: URL = URL(string: "http://localhost:8080/api/problems/random")!
    let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
        // コンソールに出力
        do{
            let couponData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            print(couponData) // Jsonの中身を表示
        }
        catch {
            print(error)
        }
        
        print("data: \(String(describing: data))")
        print("response: \(String(describing: response))")
        print("error: \(String(describing: error))")
    })
    task.resume()
}
struct CustomData : SocketData {
    let name: String
    let age: Int
    
    func socketRepresentation() -> SocketData {
        return ["name": name, "age": age]
    }
}
