import Jinx
import StoreKit

// MARK: - Server Verification Bypass
// Many apps verify receipts with their own servers

struct ServerVerificationHooks {
    
    /// Common receipt verification endpoints to intercept
    static let verificationEndpoints: [String] = [
        "/verifyReceipt",
        "/verify_receipt",
        "/receipt/verify",
        "/api/verify",
        "/api/receipt",
        "/purchase/verify",
        "/subscription/verify",
        "/iap/verify",
        "/validate",
        "/v1/receipt",
        "/v2/receipt",
        "buy.itunes.apple.com",
        "sandbox.itunes.apple.com",
        "storekit-sandbox.itunes.apple.com"
    ]
    
    /// Check if a URL is a receipt verification endpoint
    static func isVerificationURL(_ url: URL?) -> Bool {
        guard let urlString = url?.absoluteString.lowercased() else { return false }
        
        return verificationEndpoints.contains { endpoint in
            urlString.contains(endpoint.lowercased())
        }
    }
    
    /// Generate a successful server response
    static func generateSuccessResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache"
            ]
        )!
        
        // Generate appropriate response based on URL pattern
        let data: Data
        if url.absoluteString.contains("itunes.apple.com") {
            // Apple's format
            data = generateAppleReceiptResponse()
        } else {
            // Generic success for custom servers
            data = generateGenericSuccessResponse()
        }
        
        return (data, response)
    }
    
    private static func generateAppleReceiptResponse() -> Data {
        let productId = SatellaDelegate.shared.products.last?.productIdentifier ?? "com.app.premium"
        if let data = ReceiptGenerator.response(for: productId) {
            return data
        }
        // Fallback minimal response
        return Data("""
        {
            "status": 0,
            "environment": "Production",
            "receipt": {
                "bundle_id": "\(Bundle.main.bundleIdentifier ?? "com.app")",
                "in_app": []
            }
        }
        """.utf8)
    }
    
    private static func generateGenericSuccessResponse() -> Data {
        let now = Int(Date().timeIntervalSince1970)
        let expiry = now + (365 * 24 * 60 * 60) // 1 year from now
        
        return Data("""
        {
            "success": true,
            "valid": true,
            "verified": true,
            "status": "active",
            "is_subscribed": true,
            "is_premium": true,
            "has_access": true,
            "entitled": true,
            "purchase_date": \(now),
            "expiry_date": \(expiry),
            "expires_at": \(expiry),
            "expires_date_ms": "\(expiry * 1000)",
            "auto_renew_status": true,
            "subscription_status": "active",
            "entitlements": {
                "premium": {
                    "is_active": true,
                    "expires_date": "\(expiry)"
                },
                "pro": {
                    "is_active": true,
                    "expires_date": "\(expiry)"
                }
            }
        }
        """.utf8)
    }
}

// MARK: - Enhanced URL Session Hook
// Hook both data task methods

struct URLSessionDataHook: Hook {
    typealias T = @convention(c) (URLSession, Selector, URL, @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    
    let cls: AnyClass? = URLSession.self
    let sel: Selector = sel_registerName("dataTaskWithURL:completionHandler:")
    let replace: T = { obj, sel, url, handler in
        if ServerVerificationHooks.isVerificationURL(url) {
            let (data, response) = ServerVerificationHooks.generateSuccessResponse(for: url)
            
            // Create a dummy task and call handler
            let newHandler: @Sendable (Data?, URLResponse?, Error?) -> Void = { _, _, _ in
                handler(data, response, nil)
            }
            return orig(obj, sel, url, newHandler)
        }
        
        return orig(obj, sel, url, handler)
    }
}

// MARK: - Async URL Session Hook (iOS 15+)

@available(iOS 15, *)
struct URLSessionAsyncHook {
    // Note: Swift async methods are harder to hook with traditional method swizzling
    // Apps using async/await will still go through the completion handler methods
    // when using URLSession.data(from:) internally
}

// MARK: - NSURLConnection Legacy Hook
// Some older apps still use NSURLConnection

struct URLConnectionHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector, URLRequest) -> Data?
    
    let cls: AnyClass? = NSClassFromString("NSURLConnection")
    let sel: Selector = sel_registerName("sendSynchronousRequest:returningResponse:error:")
    let replace: T = { obj, sel, request in
        if ServerVerificationHooks.isVerificationURL(request.url) {
            let (data, _) = ServerVerificationHooks.generateSuccessResponse(for: request.url!)
            return data
        }
        return orig(obj, sel, request)
    }
}
