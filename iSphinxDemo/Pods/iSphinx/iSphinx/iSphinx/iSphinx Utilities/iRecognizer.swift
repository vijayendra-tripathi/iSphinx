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

open class iRecognizer {
    
    fileprivate var utilities: Utilities = Utilities()
    fileprivate var decoder: Decoder!
    fileprivate var engine: AVAudioEngine?
    fileprivate var sampRate: Double = 16000.0
    fileprivate var bufferSize: AVAudioFrameCount = 512
    fileprivate var curSpeechTime: Int = 0
    fileprivate var maxSpeechTime: Int = 0
    fileprivate var timer: Timer!
    fileprivate var hypotesis: String = ""
    fileprivate var bScore: CInt = 0
    fileprivate var endSpeechTimer: Timer!
    fileprivate var silentToDetect: Float = 1.0
    fileprivate var currentSilent: Float = 0
    fileprivate var beginSpeech: Bool = true
    fileprivate var minVoiceVolume: Float = 25.0
    fileprivate var recorder: iSphinxRecorder!
    fileprivate var isAlreadySpeech: Bool = false
    internal var delegete: iRecognizerDelegete!
    
    internal init() {}
    
    /** Init iRecognizer with config only. */
    public init(config: Config) {
        self.decoder = Decoder(config: config)
        self.sampRate = Double(config.getFloat(key: "-samprate"))
    }
    
    /** Get the decoder. */
    open func getDecoder() -> Decoder {
        return decoder
    }
    
    /** Start recognizer without timeout. */
    open func startIRecognizer() {
        self.curSpeechTime = 0
        self.maxSpeechTime = 0
        self.startListening()
    }
    
    /** Start recognizer with timeout. */
    open func startIRecognizer(timeoutInSec: Int) {
        self.curSpeechTime = 0
        self.maxSpeechTime = timeoutInSec
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.speechTimer), userInfo: nil, repeats: true)
        self.startListening()
    }
    
    /** Start recognizer from audio file 8000hz or 16000hz with single channel. */
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
        if decoder.isInSpeech() {
            if !isAlreadySpeech {
                self.isAlreadySpeech = true
                self.utilities.cancelDelay()
                self.delegete.onBeginningOfSpeech()
            }
        } else {
            if !utilities.isDelaying && isAlreadySpeech {
                self.isAlreadySpeech = false
                utilities.startDelay(delayTime: Double(silentToDetect), action: {
                    self.timer.invalidate()
                    self.delegete.onEndOfSpeech()
                })
            }
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
    
    internal func startListening() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setMode(AVAudioSessionModeMeasurement)
            try AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
            decoder.setSearch(searchName: SEARCH_ID)
            self.engine = AVAudioEngine()
            let input = engine!.inputNode
            let inFormat = input.inputFormat(forBus: 0)
            let formatIn = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: inFormat.sampleRate, channels: 1, interleaved: true)
            engine!.connect(input, to: engine!.outputNode, format: formatIn)
            self.bufferSize = AVAudioFrameCount((inFormat.sampleRate * 0.4).rounded())
            print("buffSize: \(bufferSize)")
            let sphinxFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: sampRate, channels: 1, interleaved: true)
            let fCapacity = UInt32((Float(sphinxFormat!.sampleRate) * 0.4))
            self.recorder = iSphinxRecorder(audioFormat: sphinxFormat!)
            input.installTap(onBus: 0, bufferSize: 20000, format: formatIn, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                if #available(iOS 9.0, *) {
                    let converter = AVAudioConverter.init(from: buffer.format, to: sphinxFormat!)
                    let newbuffer = AVAudioPCMBuffer(pcmFormat: sphinxFormat!,
                                                     frameCapacity: fCapacity)
                    let inputBlock : AVAudioConverterInputBlock = { (inNumPackets, outStatus) -> AVAudioBuffer? in
                        outStatus.pointee = AVAudioConverterInputStatus.haveData
                        let audioBuffer : AVAudioBuffer = buffer
                        return audioBuffer
                    }
                    var error : NSError?
                    converter!.convert(to: newbuffer!, error: &error, withInputFrom: inputBlock)
                    self.recorder.writeBuffer(pcmBuffer: newbuffer!)
                    self.processRaw(data: newbuffer!)
                }
                if let hyp = ps_get_hyp(self.decoder.getPointer(), &self.bScore) {
                    if !String.init(cString: hyp).isEmpty {
                        self.hypotesis = "\(String.init(cString: hyp))"
                        DispatchQueue.main.async {
                            self.decoder.getHypotesis().setBestScore(bScore: Int(self.bScore))
                            self.decoder.getHypotesis().setHypString(hyp: self.hypotesis)
                            self.delegete.onPartialResult(hyp: self.decoder.getHypotesis())
                        }
                    }
                }
            })
            engine!.mainMixerNode.outputVolume = 0.0
            engine!.prepare()
            decoder.startUtt()
            try engine!.start()
        } catch let error as NSError {
            decoder.endUtt()
            delegete.onError(errorDesc: error.localizedDescription)
            return
        }
    }
    
    @objc func endSpeechCheck() {
        if currentSilent == silentToDetect {
            self.beginSpeech = true
            self.delegete.onEndOfSpeech()
        }
        currentSilent += 0.1
    }
    
    @objc func speechTimer() {
        curSpeechTime += 1
        if curSpeechTime == maxSpeechTime {
            timer.invalidate()
            delegete.onTimeout()
        }
    }
    
    /** Stop speech recognition. */
    open func stopSpeech() {
        if engine != nil {
            engine!.stop()
            engine!.mainMixerNode.removeTap(onBus: 0)
            engine!.reset()
            engine = nil
            decoder.endUtt()
            DispatchQueue.main.async {
                self.delegete.onResult(hyp: self.decoder.getHypotesis())
                self.hypotesis = ""
                self.decoder.getHypotesis().setHypString(hyp: "")
                self.decoder.getHypotesis().setBestScore(bScore: 0)
            }
        }
    }
    
    /** Get the audio recorder. */
    open func getISphinxRecorder() -> iSphinxRecorder {
        return recorder
    }
    
    /** Get the silent to detect. */
    open func getSilentToDetect() -> Float {
        return silentToDetect
    }
    
    /** Set the silent to detect. */
    open func setSilentToDetect(seconds: Float) {
        self.silentToDetect = seconds
    }
}
