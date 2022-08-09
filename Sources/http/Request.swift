//
//  Request.swift
//  
//
//  Created by ericliuhusky on 2022/8/5.
//

import Foundation

public struct Request: Message {
    let firstLine: RequestLine
    let headerLines: [HeaderLine]
    public let body: Data?
}

public extension Request {
    var method: Method {
        firstLine.method
    }
    
    var path: String {
        firstLine.url.path
    }
    
    var query: String? {
        firstLine.url.query
    }
    
    var headers: [String: String] {
        headerLines.headers
    }
}

extension Request {
    struct RequestLine {
        let method: Method
        let url: URL
        let version: String
    }
}

extension Request.RequestLine: TextConvertible {
    init(text: String) {
        let fields = text.components(separatedBy: " ")
        method = Method(text: fields[0])
        url = URL(text: fields[1])
        version = fields[2]
    }
    
    var text: String {
        "\(method.text) \(url.text) \(version)\(crlf)"
    }
}
