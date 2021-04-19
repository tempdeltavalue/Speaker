//
//  ViewController.swift
//  Speaker
//
//  Created by Mykhailo Melnychuk on 19.04.2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    private lazy var dynamicLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.text = "Here's recogitions will appear"
        view.addSubview(lbl)
        
        return lbl
    }()
    
    private lazy var inputTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .white
        textField.placeholder = "Type something"
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.delegate = self
        
        view.addSubview(textField)
        
        return textField
    }()
    
    var speechRecognizer: SpeechRecognizer? = SpeechRecognizer()

    let synthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        synthesizer.delegate = self
        
        dynamicLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        dynamicLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dynamicLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dynamicLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
        inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        speechRecognizer?.record()
        speechRecognizer?.didPredict = { [weak self] text in
            self?.dynamicLabel.text = text
        }

    
        
    }
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.1


        synthesizer.speak(utterance)
    }
}

extension ViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print("utt text", utterance)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        speechRecognizer?.stopRecording()
        speechRecognizer = nil
        if let text = textField.text, text.count > 0 {
            speak(text: text)
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
}
