import Foundation

public struct Utils {
    /// Handles a deep link and extracts relevant information from it.
    /// - Parameter deeplink: The deep link URL as a string.
    /// - Returns: A `Response` object containing the extracted information from the deep link.
    public static func parseDeepLink(deeplink: String) -> Response {
        guard let url = URL(string: deeplink),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return Response(success: false, method: nil, data: nil, address: nil, state: nil)
        }
        
        var queryParams: [String: String] = [:]
        queryItems.forEach { item in
            if let value = item.value {
                queryParams[item.name] = value
            }
        }
        
        return Response(
            success: queryParams["type"] == "success",
            method: queryParams["method"],
            data: queryParams["data"],
            address: queryParams["address"],
            state: queryParams["state"]
        )
    }
    
    public static func getDeepLinkScheme(deepLink: String) -> String {
        return URL(string: deepLink)?.scheme ?? ""
    }
    
    public static func generateRandomState() -> String {
        return UUID().uuidString.lowercased()
    }
}
