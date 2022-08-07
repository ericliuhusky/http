//
//  Socket.swift
//  
//
//  Created by ericliuhusky on 2022/8/5.
//

import Foundation

class Socket {
    private let fd: Int32
    
    init(family: AddressFamily, type: `Type`, `protocol`: NetProtocol) {
        fd = socket(family.value, type.value, `protocol`.value)
    }
    
    func connect(host: String, port: Int) {
        var info: UnsafeMutablePointer<addrinfo>?
        defer {
            if info != nil {
                freeaddrinfo(info)
            }
        }
        getaddrinfo(host, String(port), nil, &info)
        
        Darwin.connect(fd, info!.pointee.ai_addr, info!.pointee.ai_addrlen)
    }
    
    func send(_ data: Data) {
        data.withUnsafeBytes { buffer in
            var sent = 0
            while sent < data.count {
                let s = Darwin.send(fd, buffer.baseAddress?.advanced(by: sent), data.count - sent, 0)
                
                sent += s
            }
        }
    }
    
    func receive() -> Data {
        var data = Data()
        let buffer = UnsafeMutableBufferPointer<CChar>.allocate(capacity: 1024)
        defer {
            buffer.deallocate()
        }
        
        var count = 0
        repeat {
            count = recv(fd, buffer.baseAddress, buffer.count, 0)
            
            let part = Data(bytes: buffer.baseAddress!, count: count)
            data.append(part)
        } while count != 0
        
        return data
    }
    
    deinit {
        shutdown(fd, SHUT_RDWR)
        close(fd)
    }
}


extension Socket {
    enum AddressFamily {
        case inet
        
        var value: Int32 {
            switch self {
            case .inet:
                return AF_INET
            }
        }
    }
    
    enum `Type` {
        case datagram
        case stream
        
        var value: Int32 {
            switch self {
            case .datagram:
                return SOCK_DGRAM
            case .stream:
                return SOCK_STREAM
            }
        }
    }
    
    enum NetProtocol {
        case udp
        case tcp
        
        var value: Int32 {
            switch self {
            case .udp:
                return IPPROTO_UDP
            case .tcp:
                return IPPROTO_TCP
            }
        }
    }
}
