//
//  WebSocketManager.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import Foundation
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
    var answeringUserName = ""
    var echoUserName = ""
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
            print("room-ready")
            
        }
        
        socket.on("room-created"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {
                    self.roomId = roomId
                }
            }
        }
        
        socket.on("room-updated"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {
                    self.roomId = roomId
                }
                if let memberNames = arr[0]["memberNames"] as? [String] {
                    self.memberNames = memberNames
                }
            }
        }
        
        socket.on("room-blocked"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let answeringUserName = arr[0]["answeringUserName"] as? String {
                    self.answeringUserName = answeringUserName
                }
            }
        }
        
        socket.on("problem-answered"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let echoUserName = arr[0]["userName"] as? String {
                    self.echoUserName = echoUserName
                }
                
                
                
            }
            
            
        }
        
        
        
        self.isWaiting = true
//        socket.connect()
        
    }
    
    func joinRoom(userId: UUID, userName: String) {
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

struct JoinRoom: SocketData {
    let userId: String
    let userName: String
    
    func socketRepresentation() -> SocketData {
        return ["userId": userId, "userName": userName]
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
