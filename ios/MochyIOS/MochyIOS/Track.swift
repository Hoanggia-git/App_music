import Foundation

struct Track: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let artworkSymbol: String
    let streamURL: URL?

    static let saved = [
        Track(title: "Night catalogue", artist: "Add a streaming URL to play", artworkSymbol: "waveform", streamURL: nil),
        Track(title: "Cloud library", artist: "Your imported tracks appear here", artworkSymbol: "music.note.list", streamURL: nil),
        Track(title: "Offline mix", artist: "Download support is planned", artworkSymbol: "arrow.down.circle", streamURL: nil)
    ]
}
