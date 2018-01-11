//
//  iSphinxRecorder.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 05/01/18.
//  Copyright © 2018 icaksama. All rights reserved.
//

import Foundation
import AVFoundation

open class iSphinxRecorder: NSObject, AVAudioPlayerDelegate {
    
    fileprivate var audioFile: AVAudioFile!
    fileprivate var didFinishPlaying: (() -> ())!
    fileprivate let audioFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(SEARCH_ID).caf")
//    fileprivate let avAudioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    fileprivate var audioPlayer: AVAudioPlayer!
    
    internal init(audioFormat: AVAudioFormat) {
        super.init()
        if !FileManager.default.fileExists(atPath: audioFileURL!.path) {
            FileManager.default.createFile(atPath: audioFileURL!.absoluteString, contents: nil, attributes: nil)
        }
        self.audioFile = try? AVAudioFile(forWriting: audioFileURL!, settings: audioFormat.settings, commonFormat: audioFormat.commonFormat, interleaved: audioFormat.isInterleaved)
    }
    
    internal func writeBuffer(pcmBuffer: AVAudioPCMBuffer) {
        do {
            try audioFile.write(from: pcmBuffer)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    open func getAudioFileURL() -> URL {
        return audioFileURL!
    }
    
    open func isPlaying() -> Bool {
        return audioPlayer.isPlaying
    }
    
    open func play(completion: @escaping() -> ()) {
        self.didFinishPlaying = completion
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setMode(AVAudioSessionModeMeasurement)
        try! AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
        self.audioPlayer = try! AVAudioPlayer(contentsOf: audioFileURL!)
        audioPlayer.delegate = self
        audioPlayer.volume = 1.0
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    open func stop() {
        audioPlayer.stop()
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.didFinishPlaying()
    }
}
