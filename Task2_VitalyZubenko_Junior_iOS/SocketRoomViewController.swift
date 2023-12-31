//
//  SocketRoomViewController.swift
//  Task2_VitalyZubenko_Junior_iOS
//
//  Created by Vitaly Zubenko on 08.09.2023.
//

import UIKit
//import Swifter

class SocketRoomViewController: UIViewController, URLSessionWebSocketDelegate {
    
//    var server: WebSocketServerMock!
    private var webSocket: URLSessionWebSocketTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        server = WebSocketServerMock()
//        startMockServer()
        connect(serverURL: "ws://localhost:8080")
    }
    
//    func startMockServer() {
//        do {
//            try server.startServer(text: { message in
//                print("RECEIVED MESSAGE FROM CLIENT: \(message)")
//            }, connected: {
//                print("CLIENT CONNECTED")
//                self.server.sendMessage("ping")
//            })
//        } catch {
//            print("SERVER START ERROR: \(error)")
//        }
//    }
    
    func connect(serverURL: String) {
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        let url = URL(string: serverURL)
        webSocket = session.webSocketTask(with: url!)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.webSocket?.resume()
        }
        
//        webSocket?.resume()
    }
    
    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("pind error: \(error)")
            }
        }
    }
    
    func close() {
        webSocket?.cancel(with: .abnormalClosure, reason: "Connection closed".data(using: .utf8))
    }
    
    func send(message: String) {
        webSocket?.send(.string(message)) { error in
            if let error = error {
                print("send error: \(error)")
            }
        }
    }
    
    private func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Received Data from Server: \(data)")
                case .string(let message):
                    print("Received String from Server: \(message)")
                    if message == "ping" {
                        self?.send(message: "pong")
                    }
                @unknown default:
                    break
                }
            case .failure(let error):
                print("receive error: \(error)")
            }

            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason")
    }
}

