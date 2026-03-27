import Foundation
import AppKit
import AVFoundation

let group = DispatchGroup()
group.enter()

var allowed = false

switch AVCaptureDevice.authorizationStatus(for: .audio) {
case .authorized:
    allowed = true
    group.leave()
case .notDetermined:
    AVCaptureDevice.requestAccess(for: .audio) { granted in
        allowed = granted
        group.leave()
    }
case .denied, .restricted:
    allowed = false
    group.leave()
@unknown default:
    allowed = false
    group.leave()
}

group.wait()

if !allowed {
    print("ERR: Microphone access denied. Please grant permission in System Settings -> Privacy & Security -> Microphone for your Terminal.")
    exit(1)
}

let engine = AVAudioEngine()
let input = engine.inputNode
let format = input.inputFormat(forBus: 0)

if format.channelCount == 0 {
    print("ERR: No microphone channels found on this Mac.")
    exit(1)
}

input.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
    guard let floatData = buffer.floatChannelData else { return }
    let frameLength = Int(buffer.frameLength)
    let channelCount = Int(format.channelCount)

    var maxAmplitude: Float = 0
    // Find the peak amplitude across all channels in this buffer
    for channel in 0..<channelCount {
        for i in 0..<frameLength {
            let val = abs(floatData[channel][i])
            if val > maxAmplitude {
                maxAmplitude = val
            }
        }
    }
    
    if maxAmplitude > 0.005 {
        print(String(format: "%.6f", maxAmplitude))
        fflush(stdout)
    }
}

do {
    try engine.start()
    RunLoop.main.run()
} catch {
    print("ERR: Could not start AVAudioEngine: \(error)")
    exit(1)
}
