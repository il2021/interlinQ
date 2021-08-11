//
//  ViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/10.
//

import UIKit
import SocketIO
class ViewController: UIViewController {
    
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
        
        socket.on("from_server"){ data, ack in
            if let message = data as? [String] {
                print(message[0])
                self.dataList.insert(message[0],at: 0)
                
            }
        }
        socket.connect()
    }

    @IBAction func tapButtonAction(_ sender: Any) {
        socket.emit("from_client", CustomData(name: "Erik", age: 24)) {
            print("送信完了")
        }
    }
    
    @IBAction func connectButtonAction(_ sender: Any) {
        socket.connect()
        
    }
    @IBAction func disconnectButtonAction(_ sender: Any) {
        socket.disconnect()
    }
    
}


struct CustomData : SocketData {
    let name: String
    let age: Int
    
    func socketRepresentation() -> SocketData {
        return ["name": name, "age": age]
    }
}
