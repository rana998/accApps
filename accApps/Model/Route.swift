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
    @AppStorage(LastRouteKey.key) private var lastRouteRaw: String = Route.ucs.rawValue

    func body(content: Content) -> some View {
        content
            .onAppear {
                lastRouteRaw = route.rawValue
            }
    }
}
