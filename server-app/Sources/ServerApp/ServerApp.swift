import Vapor
import Leaf
import Foundation
import NIO
import NIOHTTP1

actor ServerUptime {
    private var startedAt: Date = Date()

    func uptime() -> String {
        let diffComponents = Calendar.current
            .dateComponents([.hour, .minute, .second], from: startedAt, to: Date())
        let hours = diffComponents.hour ?? 0
        let minutes = diffComponents.minute ?? 0
        let seconds = diffComponents.second ?? 0
        return "\(hours)h \(minutes)m \(seconds)s"
    }
}

public func routes(instance app: Application) throws {
    let uptime: ServerUptime = ServerUptime()

    app.get("main") { req async throws -> View in 
        let interval: String = await uptime.uptime()
        let addr: SocketAddress? = req.remoteAddress
        let ip: String = addr?.ipAddress ?? "unknown"
        return try await req.view.render("main", [
                "ip": ip,
                "name": "username",
                "time": "\(interval)"
            ]
        )
    }
}

public func configure(instance app: Application) throws {
    app.views.use(.leaf)
    try routes(instance: app)
}
