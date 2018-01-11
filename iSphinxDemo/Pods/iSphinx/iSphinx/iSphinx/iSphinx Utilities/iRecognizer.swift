//
//  iSphinxRecognizer.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 20/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation
import AVFoundation

internal enum SpeechStateEnum : CustomStringConvertible {
    case Silence
    case Speech
    case Utterance
    var description: String {
        get {
            switch(self) {
            case .Silence:
                return "Silence"
            case .Speech:
                return "Speech"
            case .Utterance:
                return "Utterance"
            }
        }
    }
}

open class iRecognizer {
    
    fileprivate var decoder: Decoder!
    fileprivate var engine: AVAudioEngine!
    fileprivate var speechState: SpeechStateEnum = .Silence
    fileprivate var bufferSize: Int = 2048
    fileprivate var curSpeechTime: Int = 0
    fileprivate var maxSpeechTime: Int = 0
    internal var delegete: iRecognizerDelegete!
    
    internal init() {}
    
    public init(config: Config) {
        self.decoder = Decoder(config: config)
    }
    
    open func getDecoder() -> Decoder {
        return decoder
    }
    
    open func startIRecognizer() {
        self.curSpeechTime = 0
        self.maxSpeechTime = 0
        self.startSpeech()
    }
    
    open func startIRecognizer(timeoutInSec: Int) {
        self.curSpeechTime = 0
        self.maxSpeechTime = timeoutInSec
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.speechTimer), userInfo: nil, repeats: true)
        self.startSpeech()
    }
    
    open func startIRecognizer(file: String) {
        DispatchQueue.global(qos: .default).async {
            self.hypotesisFor(filePath: file, completion: {
                DispatchQueue.main.async {
                    self.delegete.onResult(hyp: self.decoder.getHypotesis(isFinal: true))
                }
            })
        }
    }
    
    private func process_raw(data: NSData) {
        var _ = decoder.processRaw(data: data)
        let hasSpeech = decoder.isInSpeech()
        switch (speechState) {
        case .Silence where hasSpeech:
            self.delegete.onBeginningOfSpeech()
            self.delegete.onPartialResult(hyp: self.decoder.getHypotesis(isFinal: false))
            speechState = .Speech
        case .Speech where !hasSpeech:
            self.delegete.onEndOfSpeech()
            speechState = .Utterance
        case .Utterance where !hasSpeech:
            self.delegete.onSilent()
            speechState = .Silence
        default:
            break
        }
    }
    
    private func hypotesisFor(filePath: String, completion: @escaping() -> ()) {
        if let fileHandle = FileHandle(forReadingAtPath: filePath) {
            decoder.startUtt()
            fileHandle.reduceChunks(size: bufferSize, reducer: { [unowned self] (data: NSData) in
                self.process_raw(data: data)
            })
            decoder.endUtt()
            fileHandle.closeFile()
            completion()
        } else {
            delegete.onError(errorDesc: "File cannot be read!")
        }
    }
    
    private func startSpeech() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        } catch let error as NSError {
            delegete.onError(errorDesc: error.localizedDescription)
            return
        }
        self.engine = AVAudioEngine()
        guard let input = engine?.inputNode else {
            delegete.onError(errorDesc: "Can't get input node")
            return
        }
        let formatIn = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100, channels: 1, interleaved: false)
        engine?.connect(input, to: (engine?.outputNode)!, format: formatIn)
        input.installTap(onBus: 0, bufferSize: 4096, format: formatIn,
                         block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            let audioData = Utilities.toNSData(PCMBuffer: buffer)
            self.process_raw(data: audioData)
        })
        engine.mainMixerNode.outputVolume = 0.0
        engine.prepare()
        decoder.startUtt()
        do {
            try engine?.start()
        } catch let error as NSError {
            decoder.endUtt()
            self.delegete.onError(errorDesc: error.localizedDescription)
        }
    }
    
    @objc func speechTimer() {
        curSpeechTime += 1
        if curSpeechTime == maxSpeechTime {
            delegete.onTimeout()
        }
    }
    
    open func stopSpeech() {
        decoder.endUtt()
        engine.stop()
        engine.mainMixerNode.removeTap(onBus: 0)
        engine.reset()
        engine = nil
        delegete.onResult(hyp: decoder.getHypotesis(isFinal: true))
    }
}
