
public struct Star: Codable {
    let type: String?
    let name: String?
    let isScoopable: Bool?

    var isGreat: Bool {
        guard let type else { return false }

        switch type.first {
        case "O", "B", "A":
            return false
        case "K", "M", "L", "C", "S":
            return true
        default:
            return false
            // return type.hasPrefix("White Dwarf") == true
        }
    }

    var isUseful: Bool {
        guard let type else { return false }

        switch type.first {
        case "O", "B", "A", "F", "G", "K", "M":
            return true
        default:
            // return false
            return type.hasPrefix("White Dwarf")
        }
    }
}

public struct Body: Codable {
    // let id: Int
    // let id64: Int
    // let bodyId: Int
    let name: String
    let type: String

    let subType: String?
//    let parents: [Parent]?
    let distanceToArrival: Double?
    let isLandable: Bool?
    let gravity: Double?

    var isCloseEnough: Bool {
        (distanceToArrival ?? 0) <= 2000
    }
//    let earthMasses: Double?
//    let radius: Double?
//    let surfaceTemperature: Double?
//    let surfacePressure: Double?
//    let volcanismType: String?
//    let atmosphereType: String?
//    let solidComposition: [String: Double]
//    let terraformingState: String?
//    let orbitalPeriud: Double?
//    let semiMajorExis: Double?
//    let orbitalEccentricity: Double?
//    let orbitalInclination: Double?
//    let argOfPeriapsis: Double?
//    let rotationalPeriod: Double?
//    let rotationalPeriodTidallyLocked: Bool?
//    let axialTilt: Double?
//    let materials: [String: Double]?
//    let updateTime: Date?
    // let systemId: Int
    // let systemId64: Int
    let systemName: String
}

//enum Parent: Codable {
//    case Planet(Int)
//    case Star(Int)
//    case Null(Int)
//}

public struct System: Codable {
    public struct Information: Codable {
        let allegiance: String?
        let government: String?
        let faction: String?
        let factionState: String?

        var isUnpopulated: Bool {
            allegiance == nil
        }
    }

    let id: Int
//    let id64: Int
    let primaryStar: Star
    let name: String
    let distance: Double
    let bodyCount: Int?
//    let coords: Coords
//    let date: Date
    let information: Information
}

struct OldTraits: Codable {
    let bodyCount: Int
    var landablePlanetsCount = 0
    var closePlanets = 0
    var bodies = [Body]()

    init(bodyCount: Int) {
        self.bodyCount = bodyCount
    }
}

struct Traits: Codable {
    let system: System
    var landablePlanetsCount: Int = 0
    var closePlanets = 0
    var bodies = [Body]()

    init(system: System) {
        self.system = system
    }
}