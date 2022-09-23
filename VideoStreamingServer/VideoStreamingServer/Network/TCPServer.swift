//
//  TCPServer.swift
//  TCPServerTest
//
//  Created by Jade on 2022/09/17.
//

import Foundation
import Network

/// Caution: This server can accept only one connection
class TCPServer {
    
    enum ServerError: Error {
        case invalidPortNumber
    }
    
    // MARK: - properties
    
    lazy var listeningQueue = DispatchQueue.init(label: "tcp_server_queue")
    lazy var connectionQueue = DispatchQueue.init(label: "connection_queue")
        
    var listener: NWListener?
    
    var recievedDataHandling: ((Data) -> Void)?
    
    // MARK: - methods
    
    func start(on port: UInt16) throws {
        listener?.cancel()
        
        guard let port = NWEndpoint.Port.init(rawValue: port) else {
            throw ServerError.invalidPortNumber
        }
        
        listener = try NWListener.init(using: .tcp, on: port)
                
        listener?.stateUpdateHandler = { state in
            if state == .ready {
                print("listener is ready to recieve data")
            }
        }
        
        listener?.newConnectionHandler = { [unowned self] connection in
            print("connection establised --> \(connection.endpoint)")
            
            connection.stateUpdateHandler = { [unowned self] state in
                if state == .ready {
                    recieveData(on: connection)
                }
            }
            
            connection.start(queue: connectionQueue)
        }
        
        listener?.start(queue: listeningQueue)
    }
    
    // this method receive data recursively on the connection
    private func recieveData(on connection: NWConnection) {
        if connection.state != .ready {
            return
        }
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65000) {
            [unowned self] data, _, _, error in
            if let error = error {
                print(error)
            }

            if let data = data {
                recievedDataHandling?(data)
            }

            recieveData(on: connection)
        }
    }
}
