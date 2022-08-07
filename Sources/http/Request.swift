//
//  Request.swift
//  
//
//  Created by ericliuhusky on 2022/8/5.
//

import Foundation

struct Request {
    let method: Method
    let path: String
    let query: String?
    let headers: [String: String]
    let body: Data?
    
    private var info: String {
        let querySymbol = (query == nil ? "" : "?")
        let methodText = method.rawValue
        let relativeUrl = "\(path.isEmpty ? "/" : path)\(querySymbol)\(query ?? "")"
        let httpVersion = "HTTP/1.1"
        return "\(methodText) \(relativeUrl) \(httpVersion)\(crlf)"
    }
    
    private var headersText: String {
        headers.reduce("") { partialResult, pairs in
            let key = pairs.key
            let value = pairs.value
            let headerText = "\(key): \(value)\(crlf)"
            return partialResult + headerText
        }
    }
    
    private var header: Data {
        let text = info + headersText + crlf
        return text.data(using: .utf8)!
    }
    
    var data: Data {
        header + (body ?? Data())
    }
}

extension Request {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
}
