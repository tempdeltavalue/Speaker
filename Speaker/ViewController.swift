//
//  ViewController.swift
//  Speaker
//
//  Created by Mykhailo Melnychuk on 19.04.2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        writeToFile()
    }
    
    func speak() {
        let utterance = AVSpeechUtterance(string: "Hello world")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.1

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    func writeToFile() {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "test 123")
        utterance.voice = AVSpeechSynthesisVoice(language: "en")
        var output: AVAudioFile?
        
        synthesizer.write(utterance) { buffer in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
               fatalError("unknown buffer type: \(buffer)")
            }
            
            do {
                try                output = AVAudioFile(
                    forWriting: URL(fileURLWithPath: "test.caf"),
                    settings: pcmBuffer.format.settings,
                    commonFormat: .pcmFormatInt16,
                    interleaved: false)
                try output?.write(from: pcmBuffer)

            } catch {
                
            }
        }
    }

}

