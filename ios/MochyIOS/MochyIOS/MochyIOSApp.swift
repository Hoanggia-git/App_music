// Mochy iOS is based on Mochy Music by realidkroo (GPL-3.0).
// https://github.com/realidkroo/Mochy-Music
import SwiftUI

@main
struct MochyIOSApp: App {
    @StateObject private var player = MusicPlayer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(player)
                .preferredColorScheme(.dark)
        }
    }
}
