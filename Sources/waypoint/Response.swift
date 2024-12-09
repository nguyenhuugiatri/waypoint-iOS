import Foundation

public struct Response {
    public var success: Bool?
    public var method: String?
    public var data: String?
    public var address: String?
    public var state: String?
    
    public init(success: Bool? = nil, method: String? = nil, data: String? = nil, address: String? = nil, state: String? = nil) {
        self.success = success
        self.method = method
        self.data = data
        self.address = address
        self.state = state
    }
}
