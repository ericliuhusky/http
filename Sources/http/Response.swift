//
//  Response.swift
//  
//
//  Created by ericliuhusky on 2022/8/7.
//

import Foundation

public struct Response {
    public let status: Int
    public let headers: [String: String]
    public let body: Data?

    init(data: Data) {
        let dataText = String(data: data, encoding: .utf8)!
        let parts = dataText.components(separatedBy: "\r\n\r\n")
        let headerText = parts[0]
        let bodyText = parts[1]
        
        do {
            let lines = headerText.split(separator: crlf.first!).map(String.init)
            do {
                let info = lines[0]
                let texts = info.split(separator: " ").map(String.init)
                let statusText = texts[1]
                status = Int(statusText)!
            }
            
            do {
                let headerTextList = lines.dropFirst()
                headers = headerTextList.reduce([:]) { partialResult, headerText in
                    let pairs = headerText.components(separatedBy: ": ")
                    let key = pairs[0]
                    let value = pairs[1]
                    return partialResult.merging([key: value]) { current, _ in current }
                }
            }
        }
        
        body = bodyText.data(using: .utf8)
    }
}
