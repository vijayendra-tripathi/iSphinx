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
    
    /** Init iSphinx decoder with default config, custom config or config from file. */
    public init(config: Config) {
        self.config = config
        self.pointer = ps_init(config.getPointer())
    }
    
    deinit {
        if ps_free(pointer) < 0 {
            print("Can't free decoder, it's shared among instances")
        }
    }
    
    /** Delete current decoder from memory. */
    open func delete() {
        if ps_free(pointer) < 0 {
            print("Can't free decoder, it's shared among instances")
        }
    }
    
    /** Get the current config. */
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
    
    /** Reinit the config with new config. */
    open func reinit(config: Config) {
        if ps_reinit(pointer, config.getPointer()) < 0 {
            print("Reinit decoder failed!")
        }
    }
    
    /** Load new dictionary. This function will repleace old dictionary already set. */
    open func loadDict(dictFile: String, fFilter: String?, format: String) {
        if ps_load_dict(pointer, dictFile, fFilter, format) < 0 {
            print("Load dictionary failed!")
        }
    }
    
    /** Save dictionary to file with defined format. */
    open func saveDict(dictFile: String, format: String) {
        ps_save_dict(pointer, dictFile, format)
    }
    
    /** Add new word to dictionary. phones is the pronunciation of the word. */
    open func addWord(word: String, phones: String, update: Int) {
        if ps_add_word(pointer, word, phones, Int32(update)) < 0 {
            print("Add word failed!")
        }
    }
    
    /** Set the dictionary for the first time. */
    open func setDictionary(filePath: String) {
        config.setString(key: "-dict", value: filePath)
    }
    
    /** Get the pronunciation from the current dictionary */
    open func lookupWord(word: String) -> String? {
        if let pronoun = ps_lookup_word(pointer, word) {
            return String.init(cString: pronoun)
        } else {
            return nil
        }
    }
    
    /** Get the Lattice class */
    open func getLattice() -> Lattice {
        return Lattice(decoder: self)
    }
    
    /** Start the stream. */
    open func startStream() {
        if ps_start_stream(pointer) < 0 {
            print("Start stream failed!")
        }
    }
    
    /** Start the utterance. */
    open func startUtt() {
        if ps_start_utt(pointer) < 0 {
            print("Start utt failed!")
        }
    }
    
    /** Stop the utterance. */
    open func endUtt() {
        if ps_end_utt(pointer) < 0 {
            print("End utt failed!")
        }
    }
    
    /** Process the raw data from audio input AVAudioPCMBuffer. */
    open func processRaw(data: AVAudioPCMBuffer) {
        let mBuffers = data.audioBufferList.pointee.mBuffers
        if ps_process_raw(pointer, mBuffers.mData?.assumingMemoryBound(to: int16.self), Int(mBuffers.mDataByteSize/2), 0, 0) < 0 {
            print("Cannot process raw data")
        }
    }
    
    /** Set size the raw data. */
    open func setRawData(size: Int) {
        ps_set_rawdata_size(pointer, int32(size))
    }
    
    /** Get current raw data. */
    open func getRawData() -> [Int] {
        let arrInt: [Int16] = [Int16]()
        var arrPointer: UnsafeMutablePointer<Int16>? = UnsafeMutablePointer(mutating: arrInt)
        var size: CInt = 0
        ps_get_rawdata(pointer, &arrPointer, &size)
        return [Int.init(bitPattern: arrPointer)]
    }
    
    /** Get hypotesis class. */
    internal func getHypotesis() -> Hypothesis {
        if hyoptesis == nil {
            self.hyoptesis = Hypothesis(decoder: self)
        }
        return hyoptesis
    }
    
    /** Get the probability. */
    open func getProb() -> Int {
        return Int(ps_get_prob(pointer))
    }
    
    /** Get the FrontEnd class. */
    open func getFrontEnd() -> FrontEnd {
        return FrontEnd(decoder: self)
    }
    
    /** Get the Feature class. */
    open func getFeature() -> Feature {
        return Feature(decoder: self)
    }
    
    /** Check the user in speech or not. */
    open func isInSpeech() -> Bool {
        let isInSpeech = ps_get_in_speech(pointer)
        return isInSpeech == 1 ? true : false
    }
    
    /** Get the FSG model by name. */
    open func getFsgModel(name: String) -> FsgModel {
        return FsgModel(decoder: self, name: name)
    }
    
    /** Set the FSG model. */
    open func setFsgModel(name: String, fsgModel: FsgModel) {
        if ps_set_fsg(pointer, name, fsgModel.getPointer()) < 0 {
            print("Set Fsg model failed!")
        }
    }
    
    /** Set the JSGF file. */
    open func setJsgfFile(name: String, filePath: String) {
        if ps_set_jsgf_file(pointer, name, filePath) < 0 {
            print("Set JSGF file failed!")
        }
    }
    
    /** Set the JSGF from string. */
    open func setJsgfString(name: String, gramStr: String) {
        if ps_set_jsgf_string(pointer, name, gramStr) < 0 {
            print("Set JSGF string failed")
        }
    }
    
    /** Set the Kws string. */
    open func setKws(name: String, keyFile: String) {
        if ps_set_kws(pointer, name, keyFile) < 0 {
            print("Set KWS failed!")
        }
    }
    
    /** Get the Kws string. */
    open func getKws(name: String) -> String {
        return String.init(cString: ps_get_kws(pointer, name))
    }
    
    /** Set the Keyphrase. */
    open func setKeyphrase(name: String, keyphrase: String) {
        if ps_set_keyphrase(pointer, name, keyphrase) < 0 {
            print("Set keyphrase failed!")
        }
    }
    
    /** Set the all phone with file. */
    open func setAllPhoneFile(name: String, lmFile: String) {
        if ps_set_allphone_file(pointer, name, lmFile) < 0 {
            print("Set all phone file failed!")
        }
    }
    
    /** Set the all phone with NGramModel class. */
    open func setAllPhone(name: String, nGramModel: NGramModel) {
        if ps_set_allphone(pointer, name, nGramModel.getPointer()) < 0 {
            print("Set all phone failed!")
        }
    }
    
    /** Set the language model with NGramModel. This function with replace old language model already set. */
    open func setLanguageModel(name: String, nGramModel: NGramModel) {
        if ps_set_lm(pointer, name, nGramModel.getPointer())  < 0 {
            print("Set language model failed!")
        }
    }
    
    /** Set the language model with file. This function with replace old language model already set. */
    open func setLanguageModelFile(name: String, lmPath: String) {
        if ps_set_lm_file(pointer, name, lmPath) < 0 {
            print("Set language model file failed!")
        }
    }
    
    /** Get the current language model already set. */
    open func getLanguageModel(name: String) -> NGramModel {
        return NGramModel(pointer: ps_get_lm(pointer, name))
    }
    
    /** Get the logmath class. */
    open func getLogMath() -> LogMath {
        return LogMath(decoder: self)
    }
    
    /** Set search name of language model. */
    open func setSearch(searchName: String) {
        if ps_set_search(pointer, searchName) < 0 {
            print("Set search failed!")
        }
    }
    
    /** Unset the search. */
    open func unsetSearch(searchName: String) {
        if ps_unset_search(pointer, searchName) < 0 {
            print("Unset search failed!")
        }
    }
    
    /** Get the current search name. */
    open func getSearch() -> String {
        return String.init(cString: ps_get_search(pointer))
    }
    
    /** Get the n frames. */
    open func getNFrames() -> Int {
        return Int(ps_get_n_frames(pointer))
    }
    
    /** Get the segment iterator of hypotesis. */
    open func getSegmentIterator() -> SegmentIterator {
        return SegmentIterator(decoder: self)
    }
    
    /** Get the nbest iterator of hypotesis. */
    open func getNBestIterator() -> NBestIterator {
        return NBestIterator(decoder: self)
    }
}
