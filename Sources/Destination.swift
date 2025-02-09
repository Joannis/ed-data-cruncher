import JSONCore

struct Destination: JSONTokenizerDestination {
    struct State {
        enum ParsingKey: String {
            case systemName, isLandable, distanceToArrival, name, type, gravity, unknown
        }

        var parsingKey: ParsingKey?
        var name: String?
        var type: String?
        var systemName: String?
        var isLandable: Bool?
        var distanceToArrival: Double?
        var gravity: Double?
        
        init() {}
    }

    struct ArrayStartContext {}
    struct ObjectStartContext {}
    enum Stack {
        case array, object
    }
    
    var state = State()
    var stack = [Stack]()
    let traits: AllTraits
    let pointer: UnsafePointer<UInt8>
    let count: Int

    init(pointer: UnsafePointer<UInt8>, count: Int, traits: AllTraits) {
        self.pointer = pointer
        self.count = count
        self.traits = traits
    }

    mutating func arrayStartFound(_ start: JSONToken.ArrayStart) -> ArrayStartContext {
        stack.append(.array)
        return ArrayStartContext()
    }
    mutating func arrayEndFound(_ end: JSONToken.ArrayEnd, context: consuming ArrayStartContext) {
        guard stack.removeLast() == .array else {
            fatalError()
        }

        if stack.isEmpty {
            flushState()
        }
    }

    mutating func objectStartFound(_ start: JSONToken.ObjectStart) -> ObjectStartContext {
        stack.append(.object)
        return ObjectStartContext()
    }
    mutating func objectEndFound(_ end: JSONToken.ObjectEnd, context: consuming ObjectStartContext) {
        guard stack.removeLast() == .object else {
            fatalError()
        }

        if stack.isEmpty {
            flushState()
        }
    }

    mutating func flushState() {
        if 
            let systemName = state.systemName
        {
            if state.isLandable == true {
                traits.systemTraits[systemName]?.landablePlanetsCount += 1
            }
            if let distanceToArrival = state.distanceToArrival, distanceToArrival < 1000 {
                traits.systemTraits[systemName]?.closePlanets += 1
            }
            
            traits.systemTraits[systemName]?.bodies.append(Body(
                name: state.name ?? "",
                type: state.type ?? "",
                subType: nil,
                distanceToArrival: state.distanceToArrival,
                isLandable: state.isLandable,
                gravity: state.gravity,
                systemName: systemName
            ))
        }
    }

    mutating func booleanTrueFound(_ boolean: JSONToken.BooleanTrue) {
        defer {  state.parsingKey = nil }

        switch stack.last {
        case .object:
            if let parsingKey = state.parsingKey {
                switch parsingKey {
                case .isLandable:
                    state.isLandable = true
                default:
                    ()
                }
            }
        case .array, nil:
            ()
        }
    }

    mutating func booleanFalseFound(_ boolean: JSONToken.BooleanFalse) {
        defer {  state.parsingKey = nil }
        switch stack.last {
        case .object:
            if let parsingKey = state.parsingKey {
                switch parsingKey {
                case .isLandable:
                    state.isLandable = false
                default:
                    ()
                }
            }
        case .array, nil:
            ()
        }
    }

    mutating func nullFound(_ null: JSONToken.Null) {
        defer {  state.parsingKey = nil }
    }

    mutating func stringFound(_ string: JSONToken.String) {
        let string = String(bytes: UnsafeBufferPointer(start: pointer + string.start.byteOffset + 1, count: string.byteLength - 2), encoding: .utf8)
        
        switch stack.last {
        case .object:
            if let parsingKey = state.parsingKey {
                switch parsingKey {
                case .name:
                    state.name = string
                case .systemName:
                    state.systemName = string
                case .type:
                    state.type = string
                default:
                    ()
                }

                state.parsingKey = nil
            } else {
                state.parsingKey = string.flatMap(State.ParsingKey.init) ?? .unknown
            }
        case .array, nil:
            ()
        }
    }

    mutating func numberFound(_ number: JSONToken.Number) {
        defer { state.parsingKey = nil }
        let string = String(bytes: UnsafeBufferPointer(start: pointer + number.start.byteOffset, count: number.byteLength), encoding: .utf8)
        let number = string.flatMap(Double.init)

        switch stack.last {
        case .object:
            if let parsingKey = state.parsingKey {
                switch parsingKey {
                case .distanceToArrival:
                    state.distanceToArrival = number
                case .gravity:
                    state.gravity = number
                default:
                    ()
                }
            }
        case .array, nil:
            ()
        }
    }
}