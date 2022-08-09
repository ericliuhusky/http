//
//  TextConvertible.swift
//  
//
//  Created by ericliuhusky on 2022/8/9.
//

import Foundation

protocol TextConvertible {
    init(text: String)
    var text: String { get }
}


extension Int: TextConvertible {
    init(text: String) {
        self = Int(text)!
    }
    
    var text: String {
        String(self)
    }
}

extension Data: TextConvertible {
    init(text: String) {
        self = text.data(using: .utf8)!
    }
    
    var text: String {
        String(data: self, encoding: .utf8)!
    }
}

extension URL: TextConvertible {
    init(text: String) {
        self = URL(string: text)!
    }
    
    var text: String {
        var components = URLComponents()
        components.path = path.isEmpty ? "/" : path
        components.query = query
        return components.string!
    }
}

extension Method: TextConvertible {
    init(text: String) {
        self = Method(rawValue: text)!
    }
    
    var text: String {
        rawValue
    }
}
