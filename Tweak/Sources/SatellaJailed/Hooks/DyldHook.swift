import Jinx

// Static string to avoid dangling pointer issue
private let cranePathBytes: [CChar] = Array("/usr/lib/libcrane.dylib".utf8CString)

struct DyldHook: HookFunc {
    typealias T = @convention(c) (UInt32) -> UnsafePointer<Int8>?
    
    let name: String = "_dyld_get_image_name"
    let replace: T = { index in
        let origVal: UnsafePointer<Int8>? = orig(index)

        // Check if original value contains Satella dylib name
        if let origVal {
            let origString = String(cString: origVal)
            if !origString.hasSuffix("SatellaJailed.dylib") {
                return origVal
            }
        }
        
        // Return pointer to static buffer (safe - lives for program lifetime)
        return cranePathBytes.withUnsafeBufferPointer { $0.baseAddress }
    }
}
