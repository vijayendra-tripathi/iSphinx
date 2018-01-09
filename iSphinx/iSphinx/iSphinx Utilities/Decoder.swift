//
//  Decoder.swift
//  TLSphinx
//
//  Created by Bruno Berisso on 5/29/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation
import AVFoundation
import Sphinx

public class Decoder {
    
    private var pointer: OpaquePointer!
    private var config: Config!
    private var hyoptesis: Hypothesis!
    
    public init(config: Config) {
        self.config = config
        self.pointer = ps_init(config.getPointer())
    }
    
    deinit {
        if ps_free(pointer) < 0 {
            print("Can't free decoder, it's shared among instances")
        }
    }
    
    open func delete() {
        if ps_free(pointer) < 0 {
            print("Can't free decoder, it's shared among instances")
        }
    }
    
    open func getConfig() -> Config {
        return config
    }
    
    internal static func defaultConfig() -> Config {
        return Config()!
    }
    
    internal static func fileConfig(filePath: String) -> Config {
        return Config(fromFile: filePath)!
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    open func reinit(config: Config) {
        if ps_reinit(pointer, config.getPointer()) < 0 {
            print("Reinit decoder failed!")
        }
    }
    
    open func loadDict(dictFile: String, fFilter: String?, format: String) {
        if ps_load_dict(pointer, dictFile, fFilter, format) < 0 {
            print("Load dictionary failed!")
        }
    }
    
    open func saveDict(dictFile: String, format: String) {
        ps_save_dict(pointer, dictFile, format)
    }
    
    open func addWord(word: String, phones: String, update: Int) {
        if ps_add_word(pointer, word, phones, Int32(update)) < 0 {
            print("Add word failed!")
        }
    }
    
    open func setDictionary(filePath: String) {
        config.setString(key: "-dict", value: filePath)
    }
    
    open func lookupWord(word: String) -> String? {
        if let pronoun = ps_lookup_word(pointer, word) {
            return String.init(cString: pronoun)
        } else {
            return nil
        }
    }
    
    open func getLattice() -> Lattice {
        return Lattice(decoder: self)
    }
    
    open func startStream() {
        if ps_start_stream(pointer) < 0 {
            print("Start stream failed!")
        }
    }
    
    open func startUtt() {
        if ps_start_utt(pointer) < 0 {
            print("Start utt failed!")
        }
    }
    
    open func endUtt() {
        if ps_end_utt(pointer) < 0 {
            print("End utt failed!")
        }
    }
    
    open func processRaw(data: AVAudioPCMBuffer) {
        let mBuffers = data.audioBufferList.pointee.mBuffers
        if ps_process_raw(pointer, mBuffers.mData?.assumingMemoryBound(to: int16.self), Int(mBuffers.mDataByteSize/2), 0, 0) < 0 {
            print("Cannot process raw data")
        }
    }
    
    open func setRawData(size: Int) {
        ps_set_rawdata_size(pointer, int32(size))
    }
    
    open func getRawData() -> [Int] {
        let arrInt: [Int16] = [Int16]()
        var arrPointer: UnsafeMutablePointer<Int16>? = UnsafeMutablePointer(mutating: arrInt)
        var size: CInt = 0
        ps_get_rawdata(pointer, &arrPointer, &size)
        return [Int.init(bitPattern: arrPointer)]
    }
    
    internal func getHypotesis() -> Hypothesis {
        if hyoptesis == nil {
            self.hyoptesis = Hypothesis(decoder: self)
        }
        return hyoptesis
    }
    
    open func getProb() -> Int {
        return Int(ps_get_prob(pointer))
    }
    
    open func getFrontEnd() -> FrontEnd {
        return FrontEnd(decoder: self)
    }
    
    open func getFeature() -> Feature {
        return Feature(decoder: self)
    }
    
    open func isInSpeech() -> Bool {
        let isInSpeech = ps_get_in_speech(pointer)
        return isInSpeech == 1 ? true : false
    }
    
    open func getFsgModel(name: String) -> FsgModel {
        return FsgModel(decoder: self, name: name)
    }
    
    open func setFsgModel(name: String, fsgModel: FsgModel) {
        if ps_set_fsg(pointer, name, fsgModel.getPointer()) < 0 {
            print("Set Fsg model failed!")
        }
    }
    
    open func setJsgfFile(name: String, filePath: String) {
        if ps_set_jsgf_file(pointer, name, filePath) < 0 {
            print("Set JSGF file failed!")
        }
    }
    
    open func setJsgfString(name: String, gramStr: String) {
        if ps_set_jsgf_string(pointer, name, gramStr) < 0 {
            print("Set JSGF string failed")
        }
    }
    
    open func setKws(name: String, keyFile: String) {
        if ps_set_kws(pointer, name, keyFile) < 0 {
            print("Set KWS failed!")
        }
    }
    
    open func getKws(name: String) -> String {
        return String.init(cString: ps_get_kws(pointer, name))
    }
    
    open func setKeyphrase(name: String, keyphrase: String) {
        if ps_set_keyphrase(pointer, name, keyphrase) < 0 {
            print("Set keyphrase failed!")
        }
    }
    
    open func setAllPhoneFile(name: String, lmFile: String) {
        if ps_set_allphone_file(pointer, name, lmFile) < 0 {
            print("Set all phone file failed!")
        }
    }
    
    open func setAllPhone(name: String, nGramModel: NGramModel) {
        if ps_set_allphone(pointer, name, nGramModel.getPointer()) < 0 {
            print("Set all phone failed!")
        }
    }
    
    open func setLanguageModel(name: String, nGramModel: NGramModel) {
        if ps_set_lm(pointer, name, nGramModel.getPointer())  < 0 {
            print("Set language model failed!")
        }
    }
    
    open func setLanguageModelFile(name: String, lmPath: String) {
        if ps_set_lm_file(pointer, name, lmPath) < 0 {
            print("Set language model file failed!")
        }
    }
    
    open func getLanguageModel(name: String) -> NGramModel {
        return NGramModel(pointer: ps_get_lm(pointer, name))
    }
    
    open func getLogMath() -> LogMath {
        return LogMath(decoder: self)
    }
    
    open func setSearch(searchName: String) {
        if ps_set_search(pointer, searchName) < 0 {
            print("Set search failed!")
        }
    }
    
    open func unsetSearch(searchName: String) {
        if ps_unset_search(pointer, searchName) < 0 {
            print("Unset search failed!")
        }
    }
    
    open func getSearch() -> String {
        return String.init(cString: ps_get_search(pointer))
    }
    
    open func getNFrames() -> Int {
        return Int(ps_get_n_frames(pointer))
    }
    
    open func getSegmentIterator() -> SegmentIterator {
        return SegmentIterator(decoder: self)
    }
    
    open func getNBestIterator() -> NBestIterator {
        return NBestIterator(decoder: self)
    }
}
