import SwiftUI

enum Route: String {
    case ucs
    case acs
}

struct LastRouteKey {
    static let key = "lastRoute"
}

extension View {
    func recordLastRoute(_ route: Route) -> some View {
        modifier(LastRouteRecorder(route: route))
    }
}

private struct LastRouteRecorder: ViewModifier {
    let route: Route
    // Do not seed a default; keep empty until user selects a level.
    @AppStorage(LastRouteKey.key) private var lastRouteRaw: String = ""

    func body(content: Content) -> some View {
        content
            .onAppear {
                lastRouteRaw = route.rawValue
            }
    }
}
