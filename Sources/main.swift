import Foundation
import IkigaJSON
import _NIOFileSystem
import JSONCore

func parseNewSystems() throws -> [System] {
    let systemsData = try Data(contentsOf: URL(filePath: "/workspace/systems.json"))
    var systems = try IkigaJSONDecoder().decode([System].self, from: systemsData)
    systems.sort { $0.distance < $1.distance}

    return systems
        .filter { $0.information.isUnpopulated && $0.primaryStar.isGreat }
        .filter { $0.distance < 80 }
        .filter { ($0.bodyCount ?? 0) >= 5 }
}

let data = try Data(contentsOf: URL(filePath: "/workspace/traits.json"))
var traits = try JSONDecoder().decode([String: Traits].self, from: data)

let stars = traits.values
    // .filter { $0.system.primaryStar.isGreat }
    .sorted { $0.system.distance < $1.system.distance }
    .filter { system in
        system.landablePlanetsCount >= 1 && 
        system.closePlanets >= (system.system.bodyCount ?? 0 / 2) &&
        system.system.distance <= 40
    }

print(stars.count)

for star in stars {
    print(star.system.name)
}

print("------")

for star in stars {
    print(star)
}



// let traits1Data = try Data(contentsOf: URL(filePath: "/workspace/traits-1.json"))
// let traits1 = try JSONDecoder().decode([String: OldTraits].self, from: traits1Data)
// let traits2Data = try Data(contentsOf: URL(filePath: "/workspace/traits-2.json"))
// let traits2 = try JSONDecoder().decode([String: OldTraits].self, from: traits2Data)

// let traits = AllTraits()
// let newSystems = try parseNewSystems()
// let elligibleSystemNames = newSystems.map(\.name)

// for system in elligibleSystemNames {
//     traits.systemTraits[system] = Traits(system: newSystems.first(where: { $0.name == system })!)
// }

// for (system, oldTrait) in traits1 {
//     traits.systemTraits[system]?.bodies.append(contentsOf: oldTrait.bodies)
//     traits.systemTraits[system]?.landablePlanetsCount += oldTrait.landablePlanetsCount
//     traits.systemTraits[system]?.closePlanets += oldTrait.closePlanets
// }

// for (system, oldTrait) in traits2 {
//     traits.systemTraits[system]?.bodies.append(contentsOf: oldTrait.bodies)
//     traits.systemTraits[system]?.landablePlanetsCount += oldTrait.landablePlanetsCount
//     traits.systemTraits[system]?.closePlanets += oldTrait.closePlanets
// }

// for system in elligibleSystemNames {
//     if traits.systemTraits[system]!.bodies.isEmpty {
//         traits.systemTraits[system] = nil
//     }
// }

// let results = try JSONEncoder().encode(traits.systemTraits)
// try await results.write(toFileAt: "/workspace/traits.json")