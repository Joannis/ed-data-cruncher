import Foundation
import IkigaJSON
import _NIOFileSystem
import JSONCore

public struct Star: Codable {
    let type: String?
    let name: String?
    let isScoopable: Bool?

    var isUseful: Bool {
        if isScoopable == true {
            return true
        }

        switch type?.first {
        case "O", "B", "A", "F", "G", "K", "M":
            return true
        default:
            return type?.hasPrefix("White Dwarf") == true
        }
    }
}

public struct Body: Codable {
    let id: Int
    let id64: Int
    let bodyId: Int
    let name: String
    let type: String

    let subType: String?
//    let parents: [Parent]?
    let distanceToArrival: Double?
    let isLandable: Bool?
//    let gravity: Double?
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
    let systemId: Int
    let systemId64: Int
    let systemName: String
}

//enum Parent: Codable {
//    case Planet(Int)
//    case Star(Int)
//    case Null(Int)
//}

let start = Date()
let systemsData = try Data(contentsOf: URL(filePath: "/Users/joannisorlandos/git/joannis/ed/systems.json"))
var systems = try IkigaJSONDecoder().decode([System].self, from: systemsData)
systems.sort { $0.distance < $1.distance}

let newSystems = systems
    .filter { $0.information.isNew && $0.primaryStar.isUseful }
    .filter { $0.distance < 100 }
    .filter { ($0.bodyCount ?? 0) >= 10 }

let elligibleSystemIds = newSystems.map(\.name)
let systemsFound = Date()
print("Systems found in \(systemsFound.timeIntervalSince(start))s (\(systemsData.count / 1000) kb)")

public struct System: Codable {
    public struct Information: Codable {
        let allegiance: String?
        let government: String?
        let faction: String?
        let factionState: String?

        var isNew: Bool {
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

_ = try await FileSystem.shared.withFileHandle(forReadingAt: "/Users/joannisorlandos/Downloads/bodies7days.json") { handle in
    var parser = StreamingJSONArrayDecoder<Body>()
    var interestingBodies = [Body]()
    for try await chunk in handle.readChunks() {
        let bodies = try parser.parseBuffer(chunk)

//        for body in bodies where elligibleSystemIds.contains(body.systemName) {
        for body in bodies where body.systemName == "LFT 65" {
            print(body)
            interestingBodies.append(body)
        }

//        if !bodies.isEmpty {
//            print(bodies.count)
//        }

        if parser.didReachEnd {
            return
        }
    }
}
print("Bodes found in \(systemsFound.timeIntervalSince(start))s")
