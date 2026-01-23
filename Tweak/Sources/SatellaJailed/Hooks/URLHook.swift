import Foundation
import Jinx

struct URLHook: Hook {
    typealias URLHandler = @Sendable (Data?, URLResponse?, Error?) -> Void
    typealias T = @convention(c) (URLSession, Selector, URLRequest, @escaping URLHandler) -> URLSessionDataTask

    let cls: AnyClass? = URLSession.self
    let sel: Selector = sel_registerName("dataTaskWithRequest:completionHandler:")
    let replace: T = { obj, sel, request, handler in
        // Use comprehensive server verification check
        if ServerVerificationHooks.isVerificationURL(request.url) {
            let newHandler: URLHandler = { (_, response, error) in
                autoreleasepool {
                    let url = request.url ?? URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
                    let (data, httpResponse) = ServerVerificationHooks.generateSuccessResponse(for: url)
                    handler(data, httpResponse, nil)
                }
            }

            return orig(obj, sel, request, newHandler)
        }

        return orig(obj, sel, request, handler)
    }
}
