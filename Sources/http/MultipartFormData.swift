//
//  MultipartFormData.swift
//  
//
//  Created by ericliuhusky on 2022/8/6.
//

import Foundation

public class MultipartFormData {
    let boundary = Boundary()
    private var parts: [Part]
    
    public init() {
        parts = []
    }
    
    public init(parts: [Part]) {
        self.parts = parts
    }
    
    public func append(_ part: Part) {
        parts.append(part)
    }
    
    var data: Data {
        let partsText = parts.map { part in
            let contentDisposition = "Content-Disposition: form-data"
            let nameText = "name=\"\(part.name)\""
            var fileNameText = ""
            if let fileName = part.fileName {
                fileNameText = "filename=\"\(fileName)\""
            }
            var mimeTypeText = ""
            if let mimeType = part.mimeType {
                mimeTypeText = "Content-Type: \(mimeType)"
            }
            
            let firstLine = [contentDisposition, nameText, fileNameText]
                .filter({ !$0.isEmpty })
                .joined(separator: "; ")
            
            let partText = [boundary.startText, firstLine, mimeTypeText].reduce("") { partialResult, line in
                if line.isEmpty {
                    return partialResult
                }
                return partialResult + "\(line)\(crlf)"
            }
            
            let dataText = String(data: part.data, encoding: .utf8)!
            
            return partText + crlf + dataText + crlf
        }.joined()
        
        let text = partsText + boundary.endText + crlf
        return text.data(using: .utf8)!
    }
}

extension MultipartFormData {
    struct Boundary {
        let id = UUID()
        
        var text: String {
            "\(id)"
        }
        var startText: String {
            "--\(text)"
        }
        var endText: String {
            "--\(text)--"
        }
    }
    
    public struct Part {
        let name: String
        var fileName: String? = nil
        var mimeType: String? = nil
        let data: Data
        
        public init(name: String, fileName: String? = nil, mimeType: String? = nil, data: Data) {
            self.name = name
            self.fileName = fileName
            self.mimeType = mimeType
            self.data = data
        }
    }
}
