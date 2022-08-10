//
//  Message.swift
//  
//
//  Created by ericliuhusky on 2022/8/8.
//

import Foundation

protocol Message {
    associatedtype FirstLine: TextConvertible
    var firstLine: FirstLine { get }
    var headerLines: [HeaderLine] { get }
    var body: Data? { get }
    
    init(firstLine: FirstLine, headerLines: [HeaderLine], body: Data?)
}

extension Message {
    init(message: String) {
        let parts = message.components(separatedBy: "\r\n\r\n")
        let lines = parts[0].components(separatedBy: crlf)
        let firstLine = FirstLine(text: lines[0])
        let headerLines = lines.dropFirst().map(HeaderLine.init(text:))
        let body = Data(text: parts.dropFirst().joined(separator: crlf))
        self.init(firstLine: firstLine, headerLines: headerLines, body: body)
    }
    
    var messageText: String {
        let header = headerLines.reduce("") { partialResult, headerLine in
            partialResult + headerLine.text
        }
        return firstLine.text + header + crlf + (body?.text ?? "")
    }
    
    init(message: Data) {
        let message = String(data: message, encoding: .utf8)!
        self.init(message: message)
    }
    
    var messageData: Data {
        messageText.data(using: .utf8)!
    }
}


struct HeaderLine {
    let key: String
    let value: String
}

extension HeaderLine: TextConvertible{
    init(text: String) {
        let pairs = text.components(separatedBy: ": ")
        key = pairs[0]
        value = pairs[1]
    }
    
    var text: String {
        "\(key): \(value)\(crlf)"
    }
}


extension Array where Element == HeaderLine {
    init(headers: [String: String]) {
        self = headers.map({ key, value in
            HeaderLine(key: key, value: value)
        })
    }
    
    var headers: [String: String] {
        let pairsList = map { headerLine in
            (headerLine.key, headerLine.value)
        }
        return [String: String](uniqueKeysWithValues: pairsList)
    }
}
