# http

http client and server based on POSIX socket

## HttpServer

```swift
let server = HttpServer()

server.get { req in
    "Hello, world!"
}

server.run()
```

```swift
// 查询字符串
req.query

// 原始数据
req.body

// JSON
req.json

// 表单数据
req.form
```

## HttpClient

```swift
let client = HttpClient(url: URL(string: "http://127.0.0.1:3000")!)

client.get { res in
    print(String(data: res.body!, encoding: .utf8)!)
}
```

### text/plain

```swift
client.post(data: "Hello, world!".data(using: .utf8)!) { res in

}
```

### application/json

```swift
client.post(json: ["a": 1, "b": 2]) { res in

}
```

### application/x-www-form-urlencoded

```swift
client.post(parameters: ["a": "1", "b": "2"]) { res in

}
```

### multipart/form-data

```swift
let form = MultipartFormData()
form.append(MultipartFormData.Part(name: "a", data: "1".data(using: .utf8)!))
form.append(MultipartFormData.Part(name: "b", data: "2".data(using: .utf8)!))
client.post(form: form) { res in

}
```
