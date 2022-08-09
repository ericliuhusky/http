//
//  HttpClient.swift
//  
//
//  Created by ericliuhusky on 2022/8/7.
//

import Foundation

public class HttpClient {
    public typealias CompletionBlock = (Response) -> Void
    
    public let url: URL
    public var headers: [String: String]
    
    public init(url: URL) {
        self.url = url
        headers = [:]
    }
    
    private func request(method: Method, parameters: [String: String]? = nil, body: Data? = nil, block: @escaping CompletionBlock) {
        let host = url.host!
        let port = url.port ?? 80
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let parameters = parameters {
            components?.query = urlencodedQuery(parameters: parameters)
        }
        
        let socket = Socket(family: .inet, type: .stream, protocol: .tcp)
        
        socket.connect(host: host, port: port)
        
        let request = Request(firstLine: Request.RequestLine(method: method,
                                                             url: components!.url!,
                                                             version: "HTTP/1.1"),
                              headerLines: [HeaderLine](headers: headers),
                              body: body)
        
        socket.send(request.messageData)
        
        let data = socket.receive()
        
        let response = Response(message: data)
        block(response)
    }
}

public extension HttpClient {
    func get(parameters: [String: String]? = nil, block: @escaping CompletionBlock) {
        request(method: .get, parameters: parameters, block: block)
    }
    
    func post(data: Data, block: @escaping CompletionBlock) {
        headers["Content-Type"] = "text/plain"
        headers["Content-Length"] = String(data.count)
        
        request(method: .post, body: data, block: block)
    }
    
    func post(json: [String: Any], block: @escaping CompletionBlock) {
        let data = try! JSONSerialization.data(withJSONObject: json)
        headers["Content-Type"] = "application/json"
        headers["Content-Length"] = String(data.count)
        
        request(method: .post, body: data, block: block)
    }
    
    func post(parameters: [String: String], block: @escaping CompletionBlock) {
        let data = urlencodedQuery(parameters: parameters).data(using: .utf8)!
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers["Content-Length"] = String(data.count)
        
        request(method: .post, body: data, block: block)
    }
    
    func post(form: MultipartFormData, block: @escaping CompletionBlock) {
        let boundary = form.boundary.text
        let data = form.data
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        headers["Content-Length"] = String(data.count)
        
        request(method: .post, body: data, block: block)
    }
}



let crlf = "\r\n"

func urlencodedQuery(parameters: [String: String]) -> String {
    parameters.filter { key, _ in
        !key.isEmpty
    }.map { key, value in
        "\(key)=\(value)"
    }.joined(separator: "&")
}
