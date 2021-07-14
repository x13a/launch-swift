# launch-swift

Wrapper for socket activation on macOS.

## Examle

To activate socket with `test` name:
```swift
import LaunchSocket

func main() throws {
    let fds = try LaunchSocket.activate("test").get()
    print(fds)
}

main()
```
