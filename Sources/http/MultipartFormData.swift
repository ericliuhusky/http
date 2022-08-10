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
    
    public subscript(name: String) -> Part? {
        parts.first { part in
            part.name == name
        }
    }
    
    init(boundary: Boundary, data: Data) {
        let text = String(data: data, encoding: .utf8)!
        let partsText = text.replacingOccurrences(of: "\(boundary.endText)\(crlf)", with: "")
        let partTextList = partsText.components(separatedBy: "\(boundary.startText)\(crlf)").dropFirst()
        
        parts = partTextList.map { partText in
            Part(text: partText)
        }
    }
    
    var data: Data {
        let partsText = parts.reduce("") { partialResult, part in
            partialResult + boundary.startText + crlf + part.text
        }
        
        let text = partsText + boundary.endText + crlf
        return text.data(using: .utf8)!
    }
}

extension MultipartFormData {
    struct Boundary {
        let text: String
        
        init() {
            text = UUID().uuidString
        }
        
        init(text: String) {
            self.text = text
        }
        
        var startText: String {
            "--\(text)"
        }
        var endText: String {
            "--\(text)--"
        }
    }
    
    public struct Part {
        public let name: String
        public var fileName: String? = nil
        public var mimeType: String? = nil
        public let data: Data
        
        public init(name: String, fileName: String? = nil, mimeType: String? = nil, data: Data) {
            self.name = name
            self.fileName = fileName
            self.mimeType = mimeType
            self.data = data
        }
    }
}

extension MultipartFormData.Part: TextConvertible {
    init(text: String) {
        let lines = text.components(separatedBy: crlf).filter { !$0.isEmpty }
        let fields = lines[0].components(separatedBy: "; ")
        
        let nameIndex = fields[1].range(of: "name=")!.upperBound
        let name = fields[1][nameIndex...].replacingOccurrences(of: "\"", with: "")
        
        if fields.count == 3 && lines.count == 3 {
            let fileNameIndex = fields[2].range(of: "filename=")!.upperBound
            let fileName = fields[2][fileNameIndex...].replacingOccurrences(of: "\"", with: "")
            let mimeTypeIndex = lines[1].range(of: "Content-Type: ")!.upperBound
            let mimeType = lines[1][mimeTypeIndex...].replacingOccurrences(of: "\"", with: "")
            
            self.fileName = fileName
            self.mimeType = mimeType
        }
        
        let data = lines.last!.data(using: .utf8)!
        
        self.name = name
        self.data = data
    }
    
    var text: String {
        let contentDisposition = "Content-Disposition: form-data"
        
        var partHeader = "\(contentDisposition); name=\"\(name)\"\(crlf)"
        if let fileName = fileName, let mimeType = mimeType {
            partHeader = "\(contentDisposition); name=\"\(name)\"; filename=\"\(fileName)\"\(crlf)"
            + "Content-Type: \(mimeType)\(crlf)"
        }
        
        return partHeader + crlf + data.text + crlf
    }
}
