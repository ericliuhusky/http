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
    
    private init(fd: Int32) {
        self.fd = fd
    }
    
    func bind(port: Int) {
        var addr = sockaddr_in()
        addr.sin_family = UInt8(AddressFamily.inet.value)
        addr.sin_port = UInt16(port).bigEndian
        addr.sin_addr.s_addr = INADDR_ANY.bigEndian
        
        _ = withUnsafePointer(to: addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.bind(fd, $0, UInt32(MemoryLayout.size(ofValue: addr)))
            }
        }
    }
    
    func listen(max connections: Int) {
        Darwin.listen(fd, Int32(connections))
    }
    
    func accept() -> Socket {
        var addr = sockaddr_in()
        var addrlen = socklen_t()
        
        let cfd = withUnsafeMutablePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.accept(fd, $0, &addrlen)
            }
        }
        
        return Socket(fd: cfd)
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
        let buffer = UnsafeMutableBufferPointer<CChar>.allocate(capacity: 30)
        defer {
            buffer.deallocate()
        }
        
        var flag: Int32 = 0
        var count = 0
        repeat {
            count = recv(fd, buffer.baseAddress, buffer.count, flag)
            if count < 30 {
                flag = MSG_DONTWAIT
            }
            
            guard count > 0 else { break }
            let part = Data(bytes: buffer.baseAddress!, count: count)
            data.append(part)
        } while count > 0
        
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
