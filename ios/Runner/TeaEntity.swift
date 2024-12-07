import CoreSpotlight
import AppIntents
import intelligence

// Setup for intelligence plugin
struct TeaEntity: AppEntity {
  static var defaultQuery: TeaQuery = TeaQuery()
  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Teas"))
  
  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(stringLiteral: representation)
  }
  
  let id: String
  let representation: String
}

extension TeaEntity: IndexedEntity {
  var attributeSet: CSSearchableItemAttributeSet {
    let attributes = CSSearchableItemAttributeSet()
    attributes.displayName = self.representation
    return attributes
  }
}

struct TeaQuery: EntityQuery {
  func entities(for identifiers: [String]) async throws -> [TeaEntity] {
    return IntelligencePlugin.storage.get(for: identifiers).map() { item in
      return TeaEntity(
        id: item.id,
        representation: item.representation
      )
    }
  }
  
  func suggestedEntities() async throws -> [TeaEntity] {
    return IntelligencePlugin.storage.get().map() { item in
      return TeaEntity(
        id: item.id,
        representation: item.representation
      )
    }
  }
}

extension TeaQuery: EnumerableEntityQuery {
  func allEntities() async throws -> [TeaEntity] {
    return IntelligencePlugin.storage.get().map() { item in
      return TeaEntity(
        id: item.id,
        representation: item.representation
      )
    }
  }
}
