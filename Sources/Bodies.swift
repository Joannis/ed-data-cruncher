import _NIOFileSystem
import JSONCore
import Foundation

func processBodies(atFile path: FilePath, traits: AllTraits) async throws {
    guard let info: FileInfo = try await FileSystem.shared.info(forFileAt: path), info.size > 0 else {
        print("No file at path \(path)")
        return
    }

    let start = Date()
    _ = try await FileSystem.shared.withFileHandle(forReadingAt: path) { handle in
        // var parser = StreamingJSONLinesDecoder<Body>()
        var parser = StreamingJSONArrayDecoder()
        var parsedBytes = 0
        var gbsParsed = 0
        let totalGbs = Double(info.size) / 1_000_000_000
        
        for try await chunk in handle.readChunks() {
            parsedBytes += chunk.readableBytes
            let gbs = parsedBytes / 1_000_000_000
            if gbs != gbsParsed {
                let percentage = (Double(parsedBytes) / Double(info.size)) * 100

                print("\(gbs)/\(totalGbs) GB (\(percentage)%) parsed in \(Date().timeIntervalSince(start))s")
                gbsParsed = gbs
            }

            do {
                try parser.parseBuffer(chunk) { buffer in
                    try buffer.readWithUnsafeReadableBytes { buffer in
                        return try buffer.withMemoryRebound(to: UInt8.self) { buffer in
                            let destination = Destination(pointer: buffer.baseAddress!, count: buffer.count, traits: traits)
                            var parser = JSONTokenizer(pointer: buffer.baseAddress!, count: buffer.count, destination: destination)
                            try parser.scanValue()
                            return parser.currentOffset
                        }
                    }
                }
            } catch {
                print("Rough offset: \(parsedBytes)")
                throw error
            }
        }
    }
}