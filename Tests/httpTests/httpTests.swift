import XCTest
@testable import http

final class httpTests: XCTestCase {
    func testExample() throws {
        let request = Request(firstLine: Request.RequestLine(method: .get,
                                                             url: URL(text: "/"),
                                                             version: "HTTP/1.1"),
                              headerLines: [HeaderLine](headers: ["Content-Type": "text/plain"]),
                              body: "Hello, world!".data(using: .utf8)!)
        XCTAssertEqual(request, Request(message: request.messageText))
        
        let response = Response(firstLine: Response.StatusLine(version: "HTTP/1.1",
                                                               statusCode: 200,
                                                               statusReasonPhrase: "OK"),
                                headerLines: [HeaderLine](headers: ["Content-Type": "text/plain"]),
                                body: "Hello, world!".data(using: .utf8)!)
        XCTAssertEqual(response, Response(message: response.messageText))
    }
}

extension Request: Equatable {
    public static func == (lhs: http.Request, rhs: http.Request) -> Bool {
        lhs.firstLine.method == rhs.firstLine.method &&
        lhs.firstLine.url == rhs.firstLine.url &&
        lhs.firstLine.version == rhs.firstLine.version &&
        
        lhs.headerLines.elementsEqual(rhs.headerLines, by: { l, r in
            l.key == r.key &&
            l.value == r.value
        }) &&
        
        lhs.body == rhs.body
    }
}

extension Response: Equatable {
    public static func == (lhs: http.Response, rhs: http.Response) -> Bool {
        lhs.firstLine.version == rhs.firstLine.version &&
        lhs.firstLine.statusCode == rhs.firstLine.statusCode &&
        lhs.firstLine.statusReasonPhrase == rhs.firstLine.statusReasonPhrase &&
        
        lhs.headerLines.elementsEqual(rhs.headerLines, by: { l, r in
            l.key == r.key &&
            l.value == r.value
        }) &&
        
        lhs.body == rhs.body
    }
}
