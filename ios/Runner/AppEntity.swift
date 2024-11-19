import CoreSpotlight
import AppIntents
import intelligence

// Setup for intelligence plugin
struct RepresentableEntity: AppEntity {
  static var defaultQuery: RepresentableQuery = RepresentableQuery()
  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Tea")
  
  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(stringLiteral: representation)
  }
  
  let id: String
  let representation: String
}

extension RepresentableEntity: IndexedEntity {
  var attributeSet: CSSearchableItemAttributeSet {
    let attributes = CSSearchableItemAttributeSet()
    attributes.displayName = self.representation
    return attributes
  }
}

struct RepresentableQuery: EntityQuery {
  func entities(for identifiers: [String]) async throws -> [RepresentableEntity] {
    return IntelligencePlugin.storage.get(for: identifiers).map() { item in
      return RepresentableEntity(
        id: item.id,
        representation: item.representation
      )
    }
  }
  
  func suggestedEntities() async throws -> [RepresentableEntity] {
    return IntelligencePlugin.storage.get().map() { item in
      return RepresentableEntity(
        id: item.id,
        representation: item.representation
      )
    }
  }
}

extension RepresentableQuery: EnumerableEntityQuery {
  func allEntities() async throws -> [RepresentableEntity] {
    return IntelligencePlugin.storage.get().map() { item in
      return RepresentableEntity(
        id: item.id,
        representation: item.representation
      )
    }
  }
}
