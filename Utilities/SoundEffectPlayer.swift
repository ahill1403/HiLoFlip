import AVFoundation

enum SoundEffectType: String {
    case cardDrop
    case tenPoint
    case skip
    case mustPlaySecond
    case invalidMove
}

actor SoundEffectPlayer {
    static let shared = SoundEffectPlayer()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private var enginePrepared = false

    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
    }

    func play(_ effect: SoundEffectType, enabled: Bool) async {
        guard enabled else { return }
        do {
            try startEngineIfNeeded()
            let buffer = makeBuffer(for: effect)
            player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
            player.play()
        } catch {
            print("Sound error: \(error.localizedDescription)")
        }
    }

    private func startEngineIfNeeded() throws {
        guard !engine.isRunning else { return }
        if !enginePrepared {
            engine.prepare()
            enginePrepared = true
        }
        try engine.start()
    }

    private func makeBuffer(for effect: SoundEffectType) -> AVAudioPCMBuffer {
        let duration: Double
        let baseFrequency: Double
        switch effect {
        case .cardDrop:
            duration = 0.15
            baseFrequency = 420
        case .tenPoint:
            duration = 0.25
            baseFrequency = 720
        case .skip:
            duration = 0.18
            baseFrequency = 560
        case .mustPlaySecond:
            duration = 0.2
            baseFrequency = 640
        case .invalidMove:
            duration = 0.25
            baseFrequency = 180
        }

        let totalFrames = AVAudioFrameCount(duration * format.sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames)!
        buffer.frameLength = totalFrames
        let samples = buffer.floatChannelData![0]
        let sampleRate = format.sampleRate
        let amplitude: Float = effect == .invalidMove ? 0.4 : 0.55

        for frame in 0..<Int(totalFrames) {
            let t = Double(frame) / sampleRate
            let modulation = sin(2 * Double.pi * t * 6) * 0.2
            let value = sin(2 * Double.pi * (baseFrequency + modulation * baseFrequency) * t)
            samples[frame] = Float(value) * amplitude
        }

        return buffer
    }
}
