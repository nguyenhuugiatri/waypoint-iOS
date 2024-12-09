import Foundation
import AuthenticationServices

struct CustomTabError: Error {
    let message: String
    let code: Int
}

final class CustomTab: NSObject {
    func startSession(url: URL, callbackURLScheme: String) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                switch (callbackURL, error) {
                case let (_, error?):
                    let nsError = error as NSError
                    let customTabError = CustomTabError(
                        message: nsError.localizedDescription,
                        code: nsError.code
                    )
                    continuation.resume(throwing: customTabError)
                case let (url?, nil):
                    continuation.resume(returning: url)
                case (nil, nil):
                    let customTabError = CustomTabError(
                        message: "No URL or error returned",
                        code: -1
                    )
                    continuation.resume(throwing: customTabError)
                }
            }
            
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            
            guard session.start() else {
                continuation.resume(throwing: CustomTabError(
                    message: "Failed to start session",
                    code: -2
                ))
                return
            }
        }
    }
}

extension CustomTab: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = DispatchQueue.main.sync {
            UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
        
        guard let presentationAnchor = window else {
            return ASPresentationAnchor()
        }
        
        return presentationAnchor
    }
}
