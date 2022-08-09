//
//  HttpServer.swift
//
//
//  Created by ericliuhusky on 2022/8/7.
//

import Foundation

public class HttpServer {
    public typealias CompletionBlock = (Request) -> String
    
    let port: Int
    var getBlockDict: [String: CompletionBlock]
    var postBlockDict: [String: CompletionBlock]
    
    public init(port: Int = 3000) {
        self.port = port
        getBlockDict = [:]
        postBlockDict = [:]
    }
    
    public func run() {
        let server = Socket(family: .inet, type: .stream, protocol: .tcp)
        
        server.bind(port: port)
        
        server.listen(max: 30)
        
        while true {
            let client = server.accept()
            
            let data = client.receive(capacity: 4096)
            let request = Request(message: data)
            
            var response = Response.notFound(body: "not found")
            let text: String?
            switch request.method {
            case .get:
                text = self.getBlockDict[request.path]?(request)
                
            case .post:
                text = self.postBlockDict[request.path]?(request)
            }
            if let text = text {
                response = Response.ok(body: text)
            }
            
            client.send(response.messageData)
        }
    }
}

public extension HttpServer {
    func get(_ path: String..., block: @escaping (Request) -> String) {
        getBlockDict["/" + path.joined(separator: "/")] = block
    }
    
    func post(_ path: String..., block: @escaping (Request) -> String) {
        postBlockDict["/" + path.joined(separator: "/")] = block
    }
}
