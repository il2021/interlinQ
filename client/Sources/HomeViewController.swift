//
//  HomeViewController.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/17.
//

import UIKit

class HomeViewController: UIViewController {
    var ActivityIndicator: UIActivityIndicatorView!
    let viewModel = HomeViewModel()
    var observers: [NSKeyValueObservation] = []
    @IBOutlet weak var searchingText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchingText.text = ""
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center
        
        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true
        
        // 色を設定
        ActivityIndicator.style = .medium
        
        //Viewに追加
        self.view.addSubview(ActivityIndicator)
    
        let observer1 = viewModel.observe(\.labelText) { [weak self] (viewModel, _) in
            self?.searchingText.text = viewModel.labelText
        }
        
        
        observers = [observer1]
    }
    
    
    @IBAction func tapGoButton(_ sender: Any) {
        viewModel.isLoading ? ActivityIndicator.startAnimating() : ActivityIndicator.stopAnimating()
        viewModel.buttonPressed()
        
    }
    
}

class HomeViewModel: NSObject {
    @objc dynamic private(set) var labelText: String?
    @objc dynamic private(set) var buttonIsEnabled: Bool = false
    @objc dynamic private(set) var isLoading: Bool = false
    var observers: [NSKeyValueObservation] = []
    let userId = UIDevice.current.identifierForVendor!
    
    var webSocketManager: WebSocketManager = WebSocketManager.shared
    

    func buttonPressed() {
        isLoading = true
        labelText = "検索中"
            
        webSocketManager.isConnect ? webSocketManager.disconnect() : webSocketManager.connect()
    }
}

import SocketIO
final class WebSocketManager {
    
    static let shared = WebSocketManager()
    var roomId = ""
    let manager = SocketManager(socketURL: URL(string:"http://localhost:8080/")!, config: [.log(true), .compress])
    var socket : SocketIOClient!
    var memberNames: [String] = []
    var canStart = false
    var isWaiting = true
    var isConnect = false
    
    private init() {
        
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { data, ack in
            //ack:確認応答フラグ
            print("socket connected.\ndata: \(data)\n\(ack)")
            self.isConnect = true
        }
        socket.on(clientEvent: .disconnect){data, ack in
            print("socket disconnected!")
            self.canStart = false
            self.isConnect = false
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
                
                if let memberNames = arr[0]["memberNames"] as? [String] {
                    self.memberNames = memberNames
                }
                
            }
            
            self.isWaiting = false
            self.canStart = true
 
        }
        
        socket.on("room-created"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {
                    self.roomId = roomId
                }
            }
        }
        self.isWaiting = true
        socket.connect()
        
    }
    
    func joinRoom(userId: UUID) {
        socket.emit("join-room", userId.uuidString) {
            self.isWaiting = true
        }
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    
    func startAnswer(userId: String, roomId: String) {
        socket.emit("start-answer", StartAnswer(userId: userId, roomId: roomId)) {
            self.isWaiting = true
        }
    }
    
    func submitAnswer(userId: String, roomId: String, isCorrect: Bool) {
        socket.emit("submit-answer", Answer(userId: userId, roomId: roomId, isCorrect: isCorrect))
    }
}


struct StartAnswer: SocketData {
    let userId: String
    let roomId: String
    
    func socketRepresentation() -> SocketData {
        return ["userId": userId, "roomId": roomId]
    }
}

struct Answer: SocketData {
    let userId: String
    let roomId: String
    let isCorrect: Bool
    func socketRepresentation() -> SocketData {
        return ["userId": userId, "roomId": roomId, "isCorrect": isCorrect]
    }
}
