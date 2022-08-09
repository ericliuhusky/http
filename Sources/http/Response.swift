//
//  Response.swift
//  
//
//  Created by ericliuhusky on 2022/8/7.
//

import Foundation

public struct Response: Message {
    let firstLine: StatusLine
    let headerLines: [HeaderLine]
    public let body: Data?
}

public extension Response {
    var statusCode: Int {
        firstLine.statusCode
    }
    
    var statusReasonPhrase: String {
        firstLine.statusReasonPhrase
    }
    
    var headers: [String: String] {
        headerLines.headers
    }
}

extension Response {
    struct StatusLine {
        let version: String
        let statusCode: Int
        let statusReasonPhrase: String
    }
}

extension Response.StatusLine: TextConvertible {
    init(text: String) {
        let fields = text.components(separatedBy: " ")
        version = fields[0]
        statusCode = Int(text: fields[1])
        statusReasonPhrase = fields[2]
    }
    
    var text: String {
        "\(version) \(statusCode.text) \(statusReasonPhrase)\(crlf)"
    }
}

extension Response {
    static func notFound(body: String) -> Response {
        Response(firstLine: Response.StatusLine(version: "HTTP/1.1",
                                                statusCode: 404,
                                                statusReasonPhrase: "NOT FOUND"),
                 headerLines: [HeaderLine](headers: [:]),
                 body: body.data(using: .utf8))
    }
    
    static func ok(body: String) -> Response {
        Response(firstLine: Response.StatusLine(version: "HTTP/1.1",
                                                statusCode: 200,
                                                statusReasonPhrase: "OK"),
                 headerLines: [HeaderLine](headers: [:]),
                 body: body.data(using: .utf8))
    }
}
