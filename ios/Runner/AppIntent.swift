import AppIntents
import intelligence

// Cuppa intent and shortcut definitions for intelligence plugin
struct CuppaAppIntent: AppIntent {
  static var title: LocalizedStringResource = "Brew Tea"
  static var description: LocalizedStringResource = "Start a timer to brew your cup of tea."
  static var openAppWhenRun: Bool = true
  static var isDiscoverable: Bool = true
  
  @Parameter(title: "Tea")
  var target: RepresentableEntity
  
  static var parameterSummary: some ParameterSummary {
    Summary("Start brewing \(\.$target)")
  }
  
  @MainActor
  func perform() async throws -> some IntentResult {
    IntelligencePlugin.notifier.push(target.id)
    return .result()
  }
}

struct AppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: CuppaAppIntent(),
      phrases: [
        "Start brewing \(\.$target) in \(.applicationName)",
        "Start a timer for \(\.$target) in \(.applicationName)",
        "Start timing \(\.$target) in \(.applicationName)",
      ],
      shortTitle: "Brew Tea",
      systemImageName: "clock"
    )
  }
}