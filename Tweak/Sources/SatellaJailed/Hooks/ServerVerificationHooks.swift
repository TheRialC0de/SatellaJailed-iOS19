import Jinx
import StoreKit

// MARK: - Server Verification Bypass
// Many apps verify receipts with their own servers

struct ServerVerificationHooks {
    
    /// Common receipt verification endpoints to intercept
    static let verificationEndpoints: [String] = [
        // Apple endpoints
        "/verifyReceipt",
        "/verify_receipt",
        "/receipt/verify",
        "buy.itunes.apple.com",
        "sandbox.itunes.apple.com",
        "storekit-sandbox.itunes.apple.com",
        
        // Generic API patterns
        "/api/verify",
        "/api/receipt",
        "/purchase/verify",
        "/subscription/verify",
        "/iap/verify",
        "/validate",
        "/v1/receipt",
        "/v2/receipt",
        "/check_subscription",
        "/verify_purchase",
        "/validate_receipt",
        
        // RevenueCat
        "api.revenuecat.com",
        "api.rc-backup.com",
        
        // Adapty
        "api.adapty.io",
        "api-backup.adapty.io",
        
        // Qonversion
        "api.qonversion.io",
        
        // Glassfy
        "api.glassfy.io",
        
        // Superwall
        "api.superwall.com",
        
        // Purchasely
        "api.purchasely.io",
        
        // Nami ML
        "api.namiml.com",
        
        // Common patterns
        "/entitlements",
        "/subscriber",
        "/premium",
        "/pro/status"
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
        // Safely create HTTPURLResponse with fallback
        let response: HTTPURLResponse
        if let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache"
            ]
        ) {
            response = httpResponse
        } else {
            // Fallback: create minimal valid response
            response = HTTPURLResponse(url: url, mimeType: "application/json", expectedContentLength: 0, textEncodingName: nil)
        }
        
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
        let nowMs = now * 1000
        let expiry = now + (10 * 365 * 24 * 60 * 60) // 10 years from now
        let expiryMs = expiry * 1000
        let isoNow = ISO8601DateFormatter().string(from: Date())
        let isoExpiry = ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: TimeInterval(expiry)))
        
        return Data("""
        {
            "success": true,
            "valid": true,
            "verified": true,
            "status": "active",
            "is_subscribed": true,
            "is_premium": true,
            "isPremium": true,
            "is_pro": true,
            "isPro": true,
            "has_access": true,
            "hasAccess": true,
            "entitled": true,
            "is_active": true,
            "isActive": true,
            "purchase_date": \(now),
            "purchase_date_ms": \(nowMs),
            "purchaseDate": "\(isoNow)",
            "expiry_date": \(expiry),
            "expiry_date_ms": \(expiryMs),
            "expires_at": \(expiry),
            "expires_date": "\(isoExpiry)",
            "expires_date_ms": "\(expiryMs)",
            "expiresAt": \(expiry),
            "expiresDate": "\(isoExpiry)",
            "auto_renew_status": true,
            "autoRenewStatus": true,
            "will_renew": true,
            "willRenew": true,
            "subscription_status": "active",
            "subscriptionStatus": "active",
            "subscription_type": "lifetime",
            "subscriptionType": "lifetime",
            "is_lifetime": true,
            "isLifetime": true,
            "coins": 999999999,
            "gems": 999999999,
            "credits": 999999999,
            "balance": 999999999,
            "entitlements": {
                "premium": {
                    "is_active": true,
                    "isActive": true,
                    "expires_date": "\(isoExpiry)",
                    "expiresDate": "\(isoExpiry)"
                },
                "pro": {
                    "is_active": true,
                    "isActive": true,
                    "expires_date": "\(isoExpiry)",
                    "expiresDate": "\(isoExpiry)"
                },
                "unlimited": {
                    "is_active": true,
                    "isActive": true
                }
            },
            "subscriber": {
                "entitlements": {
                    "premium": { "is_active": true },
                    "pro": { "is_active": true }
                }
            },
            "data": {
                "is_premium": true,
                "is_subscribed": true,
                "subscription_active": true
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
// Note: This hook is simplified - NSURLConnection.sendSynchronousRequest has more parameters
// For full compatibility, consider using URLProtocol instead

struct URLConnectionHook: Hook {
    // Note: The actual signature includes returningResponse and error parameters
    // This simplified version intercepts based on URL pattern
    typealias T = @convention(c) (AnyObject, Selector, URLRequest) -> Data?
    
    let cls: AnyClass? = NSClassFromString("NSURLConnection")
    let sel: Selector = sel_registerName("sendSynchronousRequest:returningResponse:error:")
    let replace: T = { obj, sel, request in
        if ServerVerificationHooks.isVerificationURL(request.url) {
            if let url = request.url {
                let (data, _) = ServerVerificationHooks.generateSuccessResponse(for: url)
                return data
            }
        }
        return orig(obj, sel, request)
    }
}
