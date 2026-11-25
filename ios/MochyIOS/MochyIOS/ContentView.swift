import SwiftUI

extension Color {
    static let mochyBackground = Color(red: 0.055, green: 0.051, blue: 0.082)
    static let mochySurface = Color(red: 0.105, green: 0.098, blue: 0.145)
    static let mochyLavender = Color(red: 0.77, green: 0.71, blue: 1.0)
    static let mochyRose = Color(red: 0.96, green: 0.68, blue: 0.76)
}

enum AppTab: Hashable { case home, search, library }

struct ContentView: View {
    @EnvironmentObject private var player: MusicPlayer
    @State private var tab: AppTab = .home
    @State private var showingPlayer = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.mochyBackground.ignoresSafeArea()
            TabView(selection: $tab) {
                HomeView(showPlayer: $showingPlayer).tag(AppTab.home).tabItem { Label("Listen", systemImage: "sparkles") }
                SearchView(showPlayer: $showingPlayer).tag(AppTab.search).tabItem { Label("Search", systemImage: "magnifyingglass") }
                LibraryView(showPlayer: $showingPlayer).tag(AppTab.library).tabItem { Label("Library", systemImage: "rectangle.stack") }
            }
            .tint(.mochyLavender)
            if player.currentTrack != nil {
                MiniPlayer(showPlayer: $showingPlayer)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 51)
            }
        }
        .sheet(isPresented: $showingPlayer) { NowPlayingView() }
    }
}

private struct HomeView: View {
    @EnvironmentObject private var player: MusicPlayer
    @Binding var showPlayer: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mochy")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                        Text("Music that stays out of your way.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 12)

                    Button { showPlayer = true } label: {
                        HStack(spacing: 16) {
                            Image(systemName: player.currentTrack?.artworkSymbol ?? "waveform")
                                .font(.system(size: 34))
                                .frame(width: 76, height: 76)
                                .background(Color.mochyRose.opacity(0.20), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(player.currentTrack?.title ?? "Your player is ready")
                                    .font(.headline)
                                Text(player.currentTrack?.artist ?? "Add a direct stream in Search")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.up")
                        }
                        .padding(16)
                        .background(Color.mochySurface, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Text("Saved for later").font(.title2.bold())
                    ForEach(Track.saved) { track in
                        TrackRow(track: track) { player.play(track: track) }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Built from Mochy Music") .font(.headline)
                        Text("This iOS port is based on Mochy Music by realidkroo and remains GPL-3.0 licensed.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(Color.mochySurface.opacity(0.7), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SearchView: View {
    @EnvironmentObject private var player: MusicPlayer
    @Binding var showPlayer: Bool
    @State private var streamURL = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Open a stream").font(.system(size: 31, weight: .bold, design: .rounded))
                Text("Paste the HTTPS address of an audio file or HLS playlist. Provider search and catalog adapters are added separately so their API terms can be respected.")
                    .font(.subheadline).foregroundStyle(.secondary)
                TextField("https://…", text: $streamURL, axis: .vertical)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(Color.mochySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                Button {
                    player.play(streamURL: streamURL.trimmingCharacters(in: .whitespacesAndNewlines))
                    showPlayer = player.currentTrack != nil
                } label: {
                    Label("Play this stream", systemImage: "play.fill")
                        .frame(maxWidth: .infinity).padding(.vertical, 15)
                        .background(Color.mochyLavender, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(Color.mochyBackground)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(20)
        }
    }
}

private struct LibraryView: View {
    @EnvironmentObject private var player: MusicPlayer
    @Binding var showPlayer: Bool

    var body: some View {
        NavigationStack {
            List {
                Section("Your library") {
                    ForEach(Track.saved) { track in
                        TrackRow(track: track) { player.play(track: track) }
                            .listRowBackground(Color.mochySurface)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.mochyBackground)
            .navigationTitle("Library")
        }
    }
}

private struct TrackRow: View {
    let track: Track
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: track.artworkSymbol)
                    .frame(width: 42, height: 42)
                    .background(Color.mochyLavender.opacity(0.16), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title).foregroundStyle(.primary)
                    Text(track.artist).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "play.fill").font(.caption).foregroundStyle(Color.mochyLavender)
            }
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }
}

private struct MiniPlayer: View {
    @EnvironmentObject private var player: MusicPlayer
    @Binding var showPlayer: Bool

    var body: some View {
        Button { showPlayer = true } label: {
            HStack(spacing: 12) {
                Image(systemName: player.currentTrack?.artworkSymbol ?? "music.note")
                    .frame(width: 38, height: 38).background(Color.mochyRose.opacity(0.22), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.currentTrack?.title ?? "").lineLimit(1)
                    Text(player.currentTrack?.artist ?? "").font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                Button(action: player.togglePlayback) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill").font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct NowPlayingView: View {
    @EnvironmentObject private var player: MusicPlayer
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Image(systemName: player.currentTrack?.artworkSymbol ?? "music.note")
                    .font(.system(size: 100, weight: .thin))
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .background(Color.mochySurface, in: RoundedRectangle(cornerRadius: 42, style: .continuous))
                VStack(alignment: .leading, spacing: 5) {
                    Text(player.currentTrack?.title ?? "Nothing playing").font(.title.bold())
                    Text(player.currentTrack?.artist ?? "Choose a stream in Search").foregroundStyle(.secondary)
                }
                Slider(value: Binding(get: { player.position }, set: { player.seek(to: $0) }), in: 0...max(player.duration, 1))
                    .tint(.mochyLavender)
                HStack { Text(time(player.position)); Spacer(); Text(time(player.duration)) }
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                Button(action: player.togglePlayback) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 30)).frame(width: 76, height: 76)
                        .background(Color.mochyLavender, in: Circle()).foregroundStyle(Color.mochyBackground)
                }
                .buttonStyle(.plain)
                Text(player.message).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Spacer(minLength: 0)
            }
            .padding(24)
            .background(Color.mochyBackground)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Done", action: dismiss.callAsFunction) } }
        }
    }

    private func time(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "--:--" }
        return String(format: "%d:%02d", Int(seconds) / 60, Int(seconds) % 60)
    }
}
