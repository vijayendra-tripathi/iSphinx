//
//  iSphinxRecognizer.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 20/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

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
    fileprivate var engine: AVAudioEngine = AVAudioEngine()
    fileprivate var speechState: SpeechStateEnum = .Silence
    fileprivate var sampRate: Double = 16000.0
    fileprivate var bufferSize: AVAudioFrameCount = 512
    fileprivate var curSpeechTime: Int = 0
    fileprivate var maxSpeechTime: Int = 0
    fileprivate var timer: Timer!
    fileprivate var hypotesis: String = ""
    fileprivate var bScore: CInt = 0
    internal var delegete: iRecognizerDelegete!
    
    internal init() {}
    
    public init(config: Config) {
        self.decoder = Decoder(config: config)
        self.sampRate = Double(config.getFloat(key: "-samprate"))
        self.bufferSize = AVAudioFrameCount(round(sampRate * 0.4))
        print("samprate: \(sampRate) - bufferSize: \(bufferSize)")
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
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.speechTimer), userInfo: nil, repeats: true)
        self.startSpeech()
    }
    
    open func startIRecognizer(file: String) {
        DispatchQueue.global(qos: .default).async {
            self.hypotesisFor(filePath: file, completion: {
                DispatchQueue.main.async {
                    self.delegete.onResult(hyp: self.decoder.getHypotesis())
                    self.hypotesis = ""
                    self.decoder.getHypotesis().setHypString(hyp: "")
                    self.decoder.getHypotesis().setBestScore(bScore: 0)
                }
            })
        }
    }
    
    private func processRaw(data: AVAudioPCMBuffer) {
        decoder.processRaw(data: data)
        let hasSpeech = decoder.isInSpeech()
        switch (speechState) {
        case .Silence where hasSpeech:
            self.delegete.onBeginningOfSpeech()
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
            fileHandle.reduceChunks(size: Int(bufferSize), reducer: { (data) in
                self.processRaw(data: Utilities.toPCMBuffer(data: data))
                if let hyp = ps_get_hyp(self.decoder.getPointer(), &self.bScore) {
                    if !String.init(cString: hyp).isEmpty {
                        self.hypotesis += "\(String.init(cString: hyp)) "
                        self.decoder.endUtt()
                        self.decoder.getHypotesis().setBestScore(bScore: Int(self.bScore))
                        self.decoder.getHypotesis().setHypString(hyp: self.hypotesis)
                        DispatchQueue.main.async {
                            self.delegete.onPartialResult(hyp: self.decoder.getHypotesis())
                        }
                        self.decoder.startUtt()
                    }
                }
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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setMode(AVAudioSessionModeMeasurement)
            try AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
            decoder.setSearch(searchName: SEARCH_ID)
            let input = engine.inputNode
            let inFormat = input.inputFormat(forBus: 0)
            let formatIn = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: inFormat.sampleRate, channels: inFormat.channelCount, interleaved: inFormat.isInterleaved)
            engine.connect(input, to: engine.outputNode, format: formatIn)
            input.installTap(onBus: 0, bufferSize: AVAudioFrameCount((inFormat.sampleRate * 0.4).rounded()) , format: formatIn, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                let newFormatIn = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: self.sampRate, channels: buffer.format.channelCount, interleaved: true)
                if #available(iOS 9.0, *) {
                    let converter = AVAudioConverter.init(from: buffer.format, to: newFormatIn!)
                    let fCapacity = UInt32(Float(newFormatIn!.sampleRate) * 0.4)
                    let newbuffer = AVAudioPCMBuffer(pcmFormat: newFormatIn!,
                                                     frameCapacity: fCapacity)
                    let inputBlock : AVAudioConverterInputBlock = { (inNumPackets, outStatus) -> AVAudioBuffer? in
                        outStatus.pointee = AVAudioConverterInputStatus.haveData
                        let audioBuffer : AVAudioBuffer = buffer
                        return audioBuffer
                    }
                    var error : NSError?
                    converter!.convert(to: newbuffer!, error: &error, withInputFrom: inputBlock)
                    self.processRaw(data: newbuffer!)
                } else {
                    var acr: AudioConverterRef? = nil
                    let _ = AudioConverterNew(buffer.format.streamDescription, newFormatIn!.streamDescription, &acr)
                    let newbuffer = AVAudioPCMBuffer(pcmFormat: newFormatIn!,
                                                     frameCapacity: AVAudioFrameCount(newFormatIn!.sampleRate * 0.4))
                    self.processRaw(data: newbuffer!)
                }
                if let hyp = ps_get_hyp(self.decoder.getPointer(), &self.bScore) {
                    if !String.init(cString: hyp).isEmpty {
                        self.hypotesis += "\(String.init(cString: hyp)) "
                        self.decoder.endUtt()
                        DispatchQueue.main.async {
                            self.decoder.getHypotesis().setBestScore(bScore: Int(self.bScore))
                            self.decoder.getHypotesis().setHypString(hyp: self.hypotesis)
                            self.delegete.onPartialResult(hyp: self.decoder.getHypotesis())
                        }
                        self.decoder.startUtt()
                    }
                }
            })
            engine.mainMixerNode.outputVolume = 0.0
            engine.prepare()
            decoder.startUtt()
            try engine.start()
        } catch let error as NSError {
            decoder.endUtt()
            delegete.onError(errorDesc: error.localizedDescription)
            return
        }
    }
    
    @objc func speechTimer() {
        curSpeechTime += 1
        if curSpeechTime == maxSpeechTime {
            timer.invalidate()
            delegete.onTimeout()
            stopSpeech()
        }
    }
    
    open func stopSpeech() {
        engine.stop()
        engine.mainMixerNode.removeTap(onBus: 0)
        engine.inputNode.removeTap(onBus: 0)
        engine.outputNode.removeTap(onBus: 0)
        engine.reset()
        decoder.endUtt()
        DispatchQueue.main.async {
            self.delegete.onResult(hyp: self.decoder.getHypotesis())
            self.hypotesis = ""
            self.decoder.getHypotesis().setHypString(hyp: "")
            self.decoder.getHypotesis().setBestScore(bScore: 0)
        }
    }
}
