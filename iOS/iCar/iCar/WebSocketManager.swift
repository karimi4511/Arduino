//
//  WebSocketManager.swift
//  iCar
//
//  Created by Viktor Levshchanov on 4/3/17.
//  Copyright © 2017 Viktor Levshchanov. All rights reserved.
//

import Foundation
import SwiftWebSocket

protocol WebSocketManagerDelegate: NSObjectProtocol {
    func socketStateDidChanged(socketManager: WebSocketManager)
    func socketDidFailed(socketManager: WebSocketManager, error: Error)
}

class WebSocketManager {
    
    private let address = "ws://192.168.4.22:81"
    private let socket = WebSocket()
    
    var connected = false
    var error: Error?
    weak var delegate: WebSocketManagerDelegate?
    
    init(delegate: WebSocketManagerDelegate? = nil) {
        self.delegate = delegate
        socket.event.open = { [unowned self] in
            DispatchQueue.main.async {
                print("connected")
                self.connected = true
                self.delegate?.socketStateDidChanged(socketManager: self)
            }
        }
        socket.event.close = { [unowned self] (code, reason, clean) in
            DispatchQueue.main.async {
                print("disconnected")
                self.connected = false
                self.delegate?.socketStateDidChanged(socketManager: self)
            }
        }
        socket.event.error = { [unowned self] (error) in
            print("error: \(error)")
            self.connected = false
            self.error = error
            self.delegate?.socketDidFailed(socketManager: self, error: error)
        }
    }
    
    func open() {
        if(connected) {
            close()
        }
        socket.open(address)
    }
    
    func close() {
        socket.close()
    }
    
    func sendMessage(message: String) {
        if(connected) {
            socket.send(message)
        }
    }
    
}
