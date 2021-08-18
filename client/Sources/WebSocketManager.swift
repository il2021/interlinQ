//
//  WebSocketManager.swift
//  client
//
//  Created by TanakaHirokazu on 2021/08/18.
//

import Foundation
import SocketIO

protocol WebSocketDelegate: AnyObject {
    func ready()
    func createRoom(_ roomId: String)
}

final class WebSocketManager {
    weak var delegate: WebSocketDelegate?
    
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
    var echoIsCorrect = false
    var winnerName = ""
    var succeeded = false
    var quiz = Quiz(id: nil, available: nil, question: nil, answer: nil, answerInKana: nil)
    
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
        
//         MARK: 部屋の準備が整った時
        socket.on("room-ready"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {
                    self.roomId = roomId
                    QuizClient.fetchNextQuiz(roomId: roomId) { quiz in
                        precondition(quiz.available != false)
                        self.quiz = quiz
                    }
                }

                if let memberNames = arr[0]["memberNames"] as? [String] {
                    self.memberNames = memberNames
                }

            }

            self.isWaiting = false
            self.canStart = true
            self.delegate?.ready()
        }
        
        socket.on("room-created"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let roomId = arr[0]["roomId"] as? String {
                    self.roomId = roomId
                    print("room-created内: \(roomId)")
                    self.delegate?.createRoom(roomId)
                }
                print("room作成完了")
            }
            
        }

        socket.on("room-blocked"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let answeringUserName = arr[0]["answeringUserName"] as? String {
                    self.answeringUserName = answeringUserName
                }
            }
            print("誰かが回答中 \(self.answeringUserName)")
            //TODO:回答者のみがボタンを押せる
        }
        
        socket.on("problem-answered"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let echoUserName = arr[0]["userName"] as? String {
                    self.echoUserName = echoUserName
                }
                
                if let echoIsCorrect = arr[0]["isCorrect"] as? Bool {
                    self.echoIsCorrect = echoIsCorrect
                }
                
            }
            
            print("相手の回答が正解か不正解か")

        }
        
        socket.on("room-closed"){ data, ack in
            if let arr = data as? [[String: Any]] {
                if let succeeded = arr[0]["succeeded"] as? Bool {
                    self.succeeded = succeeded
                }
                
                if let winnerName = arr[0]["winnerName"] as? String {
                    self.winnerName = winnerName
                }
                
            }
            
            print("ルームを閉じる")
            
        }
        
    
        socket.connect()
        
    }
    
    func joinRoom(userId: UUID, userName: String) {
        socket.emit("join-room", JoinRoom(userId: userId.uuidString, userName: userName)) {
            self.isWaiting = true
        }
    }
    
    func connect() {
        socket.connect()
        print("接続処理")
    }
    
    func disconnect() {
        socket.disconnect()
        print("切断処理")
    }
    
    
    func startAnswer(userId: String, roomId: String) {
        socket.emit("start-answer", StartAnswer(userId: userId, roomId: roomId)) {
            self.isWaiting = true
        }
        print("回答を始める")
    }
    
    func submitAnswer(userId: String, roomId: String, isCorrect: Bool) {
        socket.emit("submit-answer", Answer(userId: userId, roomId: roomId, isCorrect: isCorrect))
        print("回答を提出する")
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
