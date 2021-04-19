import AVFoundation
import Foundation
import Speech
import SwiftUI

final class SpeechRecognizer {
    // Calls when "hear" and predict finished voice for text with whole record value
    var didPredict: ((String?) -> ())?
    
    private class SpeechAssist {
        var audioEngine: AVAudioEngine?
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        let speechRecognizer = SFSpeechRecognizer()

        deinit {
            reset()
        }

        func reset() {
            recognitionTask?.cancel()
            audioEngine?.stop()
            audioEngine = nil
            recognitionRequest = nil
            recognitionTask = nil
        }
    }

    private let assistant = SpeechAssist()

    func record() {
        canAccess { [weak self] authorized in
            self?.assistant.audioEngine = AVAudioEngine()
            guard let audioEngine = self?.assistant.audioEngine else {
                fatalError("Unable to create audio engine")
            }
            self?.assistant.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = self?.assistant.recognitionRequest else {
                fatalError("Unable to create request")
            }
            recognitionRequest.shouldReportPartialResults = true

            do {

                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                let inputNode = audioEngine.inputNode

                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                    recognitionRequest.append(buffer)
                }
//                relay(speech, message: "Preparing audio engine")
                audioEngine.prepare()
                try audioEngine.start()
                self?.assistant.recognitionTask = self?.assistant.speechRecognizer?.recognitionTask(with: recognitionRequest) { (result, error) in
                    self?.didPredict?(result?.bestTranscription.formattedString)
                    var isFinal = false
                    if let result = result {
//                        relay(speech, message: result.bestTranscription.formattedString)
                        isFinal = result.isFinal
                    }

                    if error != nil || isFinal {
                        audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        self?.assistant.recognitionRequest = nil
                    }
                }
            } catch {
                print("Error transcibing audio: " + error.localizedDescription)
                self?.assistant.reset()
            }
        }
    }
    
    func stopRecording() {
        assistant.reset()
    }
    private func canAccess(withHandler handler: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized {
                AVAudioSession.sharedInstance().requestRecordPermission { authorized in
                    handler(authorized)
                }
            } else {
                handler(false)
            }
        }
    }
}
