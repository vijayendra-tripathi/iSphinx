//
//  iSphinx.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 19/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class iSphinx: iRecognizerDelegete {
    
    fileprivate var recognizer: iRecognizer!
    fileprivate var recognizerTemp: iRecognizer!
    fileprivate var config: Config!
    fileprivate var nGramModel: NGramModel?
    fileprivate let fileManager = FileManager.default
    fileprivate let dictPathTemp = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(SEARCH_ID)-dict.txt")
    
    open var delegete: iSphinxDelegete!
    
    public init() {}
    
    open func startISphinx() {
        recognizer.startIRecognizer()
    }
    
    open func startISphinx(timeoutInSec: Int) {
        recognizer.startIRecognizer(timeoutInSec: timeoutInSec)
    }
    
    open func prepareISphinx(onPreExecute: @escaping(_ config: Config) -> (),
                             onPostExecute: @escaping(_ isSuccess: Bool) -> ()) {
        let dictionary = Utilities.getAssetPath()?.appending("\(SEARCH_ID).txt")
        self.config = iRecognizerSetup.defaultSetup().getRecognizer().getDecoder().getConfig()
//        "-fwdflat", "yes",
//        "-bestpath", "yes",
//        config.setString(key: "-beam", value: "1.000000e-80")
//        config.setString(key: "-wbeam", value: "1.000000e-40")
//        config.setInteger(key: "-ds", value: 2)
//        config.setBoolean(key: "-fwdflat", value: true)
//        config.setBoolean(key: "-bestpath", value: true)
//        config.setInteger(key: "-topn", value: 2)
//        config.setInteger(key: "-maxwpf", value: 5)
//        config.setInteger(key: "-maxhmmpf", value: 3000)
        config.setBoolean(key: "-verbose", value: true)
        config.setString(key: "-dict", value: dictionary)
        config.setFloat(key: "-vad_threshold", value: 3);
        config.setFloat(key: "-lw", value: 6.5);
        onPreExecute(config)
        recognizer = iRecognizer(config: config)
        recognizerTemp = iRecognizer(config: config)
        recognizer.delegete = self
        onPostExecute(true)
    }
    
    open func prepareISphinx(lmFile: String, aModelPath: String, dictFile: String?, onPreExecute: @escaping(_ config: Config) -> (),
                             onPostExecute: @escaping(_ isSuccess: Bool) -> ()) {
        let dictionary = Utilities.getAssetPath()?.appending("\(SEARCH_ID).txt")
        self.config = Config(args: ("-hmm", aModelPath))
        config.setString(key: "-dict", value: dictFile == nil ? dictionary : dictFile)
        config.setString(key: "-lm", value: lmFile)
        config.setInteger(key: "-samprate", value: 16000);
        config.setFloat(key: "-vad_threshold", value: 3);
        config.setFloat(key: "-lw", value: 6.5);
        onPreExecute(config)
        recognizer = iRecognizer(config: config)
        recognizerTemp = iRecognizer(config: config)
        recognizer.delegete = self
        onPostExecute(true)
    }
    
    open func prepareISphinx(aModelPath: String, dictFile: String?, onPreExecute: @escaping(_ config: Config) -> (),
                             onPostExecute: @escaping(_ isSuccess: Bool) -> ()) {
        let dictionary = Utilities.getAssetPath()?.appending("\(SEARCH_ID).txt")
        self.config = Config(args: ("-hmm", aModelPath))
        config.setString(key: "-dict", value: dictFile == nil ? dictionary : dictFile)
        config.setInteger(key: "-samprate", value: 16000);
        config.setFloat(key: "-vad_threshold", value: 3);
        config.setFloat(key: "-lw", value: 6.5);
        onPreExecute(config)
        recognizer = iRecognizer(config: config)
        recognizerTemp = iRecognizer(config: config)
        recognizer.delegete = self
        onPostExecute(true)
    }
    
    fileprivate func generateDictionary(words: [String]) {
        var text = ""
        for word in words {
            let lookup = recognizerTemp.getDecoder().lookupWord(word: word.lowercased())
            text += "\(word.lowercased()) \(lookup)\n"
        }
        try? text.write(to: dictPathTemp!, atomically: true, encoding: .utf8)
//        recognizer.getDecoder().setDictionary(filePath: dictPathTemp!.absoluteString)
        recognizer.getDecoder().loadDict(dictFile: dictPathTemp!.absoluteString, fFilter: nil, format: "dict")
    }
    
    fileprivate func generateNGramModel(words: [String]) {
        let arpaFile = Utilities.getAssetPath()!.appending("\(SEARCH_ID).arpa")
        nGramModel = NGramModel(config: config, logMath: recognizer.getDecoder().getLogMath(), lmFile: arpaFile)
        for word in words {
            nGramModel?.addWord(word: word.lowercased(), weight: 1.7)
        }
        recognizer.getDecoder().setLanguageModel(name: SEARCH_ID, nGramModel: nGramModel!)
    }
    
    open func updateVocabulary(text: String, completion: @escaping() -> ()) {
        let words: [String] = text.components(separatedBy: " ").removeDuplicates()
        self.generateDictionary(words: words)
        self.generateNGramModel(words: words)
        completion()
    }
    
    open func updateVocabulary(words: [String], completion: @escaping() -> ()) {
        self.generateDictionary(words: words.removeDuplicates())
        self.generateNGramModel(words: words.removeDuplicates())
        completion()
    }
    
    func onBeginningOfSpeech() {
        delegete.iSphinxDidSpeechDetected()
    }
    
    func onEndOfSpeech() {
//        recognizer.stopSpeech()
        delegete.iSphinxDidStop(reason: "End of speech", code: 200)
    }
    
    func onPartialResult(hyp: Hypothesis?) {
        if hyp != nil {
            if !hyp!.getHypString().isEmpty {
                delegete.iSphinxPartialResult(partialResult: hyp!.getHypString())
            }
        }
    }
    
    func onResult(hyp: Hypothesis?) {
        if hyp != nil {
            if !hyp!.getHypString().isEmpty {
                delegete.iSphinxFinalResult(result: hyp!.getHypString(), hypArr: ["a"], scores: [0])
            }
        }
    }
    
    func onError(errorDesc: String) {
        recognizer.stopSpeech()
        delegete.iSphinxDidStop(reason: errorDesc, code: 500)
    }
    
    func onTimeout() {
        recognizer.stopSpeech()
        delegete.iSphinxDidStop(reason: "Speech timeout", code: 522)
    }
    
    func onSilent() {
        print("Silent detected!")
    }
}
