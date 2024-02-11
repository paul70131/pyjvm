from pyjvm.jvm import Jvm

from pyjvm.bytecode.annotations import Method, Object

import requests
import traceback



options = {
    "Xcheck:jni": None,
}

jvm = Jvm.create(**options)
jvm._export_generated_classes = True


Object = jvm.findClass("java/lang/Object")


HttpServer = jvm.findClass("com/sun/net/httpserver/HttpServer")
InetSocketAddress = jvm.findClass("java/net/InetSocketAddress")
HttpHandler = jvm.findClass("com/sun/net/httpserver/HttpHandler")
HttpExchange = jvm.findClass("com/sun/net/httpserver/HttpExchange")

response = "Hello, PyJVM!"
port = 31831


class MyHandler(Object, HttpHandler):
    package = "example.http"

    @Method
    def handle(self, exchange: HttpExchange):
        exchange.sendResponseHeaders(200, len(response))
        for byte in response.encode("utf-8"):
            exchange.getResponseBody().write(byte)
        exchange.getResponseBody().close()

server = HttpServer.create(InetSocketAddress(port), 0)
server.createContext("/", MyHandler())
server.setExecutor(None)
server.start()



r = requests.get(f"http://localhost:{port}")

assert r.status_code == 200
assert r.text == response

print(r.text)