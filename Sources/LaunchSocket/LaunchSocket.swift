import Foundation
import System
import Swift

public struct LaunchSocket {
    
    public enum Error: Swift.Error, LocalizedError {
        case notExist
        case notManaged
        case alreadyActivated
        case rv(Int32)
        
        public var errorDescription: String? {
            switch self {
            case .notExist: return "The socket name specified does not exist in the caller's launchd.plist"
            case .notManaged: return "The calling process is not managed by launchd"
            case .alreadyActivated: return "The specified socket has already been activated"
            case .rv(let rv):
                if #available(macOS 11.0, *) {
                    return System.Errno.init(rawValue: rv).localizedDescription
                } else {
                    return String(cString: strerror(rv))
                }
            }
        }
        
    }
    
    public static func activate(_ name: String) -> Result<[Int32], Error> {
        var fds = UnsafeMutablePointer<CInt>.init(bitPattern: 0xdeadbeef)!
        var cnt: size_t = 0
        let rv = launch_activate_socket(name, &fds, &cnt)
        guard rv == 0 else {
            switch rv  {
            case ENOENT: return .failure(.notExist)
            case ESRCH: return .failure(.notManaged)
            case EALREADY: return .failure(.alreadyActivated)
            default: return .failure(.rv(rv))
            }
        }
        defer { fds.deallocate() }
        var result = [Int32]()
        for i in 0..<cnt {
            result.append(fds[i])
        }
        return .success(result)
    }
}
