import AVFoundation
import MediaPlayer

@MainActor
final class MusicPlayer: NSObject, ObservableObject {
    @Published private(set) var currentTrack: Track?
    @Published private(set) var isPlaying = false
    @Published private(set) var position: Double = 0
    @Published private(set) var duration: Double = 0
    @Published var message = "Paste an HTTPS audio or HLS URL to start listening."

    private let player = AVPlayer()
    private var timeObserver: Any?

    override init() {
        super.init()
        configureAudioSession()
        configureRemoteCommands()
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            self.position = max(0, time.seconds.isFinite ? time.seconds : 0)
            let seconds = self.player.currentItem?.duration.seconds ?? 0
            self.duration = seconds.isFinite ? max(0, seconds) : 0
            self.updateNowPlaying()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(itemFinished),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    deinit {
        if let timeObserver { player.removeTimeObserver(timeObserver) }
        NotificationCenter.default.removeObserver(self)
    }

    func play(track: Track) {
        guard let url = track.streamURL else {
            message = "This item has no stream yet. Open Search and paste an HTTPS audio or HLS URL."
            return
        }
        currentTrack = track
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        isPlaying = true
        message = "Streaming (track.title)"
        updateNowPlaying()
    }

    func play(streamURL rawURL: String) {
        guard let url = URL(string: rawURL), url.scheme?.lowercased() == "https" else {
            message = "Use a complete HTTPS URL for an audio file or HLS playlist."
            return
        }
        play(track: Track(title: "Direct stream", artist: url.host ?? "Online", artworkSymbol: "dot.radiowaves.left.and.right", streamURL: url))
    }

    func togglePlayback() {
        guard currentTrack != nil else {
            message = "Choose a stream first."
            return
        }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        updateNowPlaying()
    }

    func seek(to seconds: Double) {
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    @objc private func itemFinished() {
        isPlaying = false
        position = 0
        updateNowPlaying()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            message = "Audio session could not be activated: \(error.localizedDescription)"
        }
    }

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self, self.currentTrack != nil else { return .commandFailed }
            self.player.play(); self.isPlaying = true; self.updateNowPlaying()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.player.pause(); self?.isPlaying = false; self?.updateNowPlaying()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: event.positionTime)
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let track = currentTrack else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: position,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1 : 0
        ]
    }
}
