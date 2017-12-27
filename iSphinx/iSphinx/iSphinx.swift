//
//  iSphinx.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 19/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class iSphinx: iRecognizerDelegete {
    
    fileprivate let SEARCH_ID = "icaksama"
    fileprivate var recognizer: iRecognizer!
    fileprivate var recognizerTemp: iRecognizer!
    fileprivate var config: Config!
    fileprivate var nGramModel: NGramModel?
    fileprivate let fileManager = FileManager.default
    open var delegete: iSphinxDelegete!
    
    fileprivate func getAssetPath() -> String? {
        return Bundle(for: iSphinx.self).path(forResource: "Resources", ofType: nil)
    }
    
    public init() {}
    
    open func startISphinx() {
        recognizer.startIRecognizer()
    }
    
    open func startISphinx(timeoutInSec: Int) {
        recognizer.startIRecognizer(timeoutInSec: timeoutInSec)
    }
    
    open func prepareISphinx(onPreExecute: @escaping(_ config: Config) -> (),
                             onPostExecute: @escaping(_ isSuccess: Bool) -> ()) {
        let acousticModel = getAssetPath()?.appending("en-us-ptm")
        let dictionary = getAssetPath()?.appending("cmudict-en-us.dict")
        config.setString(key: "-hmm", value: acousticModel)
        config.setString(key: "-dict", value: dictionary)
        config.setFloat(key: "-vad_threshold", value: 16000);
        config.setFloat(key: "-lw", value: 6.5);
        onPreExecute(config)
        recognizer = iRecognizer(config: config)
        recognizerTemp = iRecognizer(config: config)
        recognizer.delegete = self
        onPostExecute(true)
    }
    
    open func prepareISphinx(lmFile: String, dictFile: String?, onPreExecute: @escaping(_ config: Config) -> (),
                             onPostExecute: @escaping(_ isSuccess: Bool) -> ()) {
        let acousticModel = getAssetPath()?.appending("en-us-ptm")
        let dictionary = getAssetPath()?.appending("cmudict-en-us.dict")
        config.setString(key: "-hmm", value: acousticModel)
        if dictFile == nil {
            config.setString(key: "-dict", value: dictionary)
        } else {
            config.setString(key: "-dict", value: dictFile)
        }
        config.setString(key: "-lm", value: lmFile)
        config.setFloat(key: "-vad_threshold", value: 16000);
        config.setFloat(key: "-lw", value: 6.5);
        onPreExecute(config)
        recognizer = iRecognizer(config: config)
        recognizerTemp = iRecognizer(config: config)
        recognizer.delegete = self
        onPostExecute(true)
    }
    
    fileprivate func generateDictionary(words: [String]) {
        var text = ""
        let dictPath = NSURL(fileURLWithPath: (getAssetPath()?.appending("\(SEARCH_ID).dict"))!, isDirectory: false)
        if fileManager.fileExists(atPath: dictPath.absoluteString!) {
            try? fileManager.removeItem(at: dictPath.absoluteURL!)
        }
        for word in words {
            let lookup = recognizerTemp.getDecoder().lookupWord(word: word)
            text += text + " " + lookup + "\n"
        }
        try? text.write(to: dictPath.absoluteURL!, atomically: false, encoding: String.Encoding.utf8)
        recognizer.getDecoder().getConfig().setString(key: "-dict", value: dictPath.absoluteString!)
    }
    
    fileprivate func generateNGramModel(words: [String]) {
        if nGramModel != nil {
            recognizer.getDecoder().getLanguageModel(name: SEARCH_ID).delete()
            recognizer.getDecoder().unsetSearch(searchName: SEARCH_ID)
            nGramModel = nil
        }
        let arpaFile = getAssetPath()?.appending("\(SEARCH_ID).arpa")
        nGramModel = NGramModel(config: config, logMath: recognizer.getDecoder().getLogMath(), lmFile: arpaFile!)
        for word in words {
            nGramModel?.addWord(word: word, weight: 1.7)
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
        recognizer.stopSpeech()
        delegete.iSphinxDidStop(reason: "End of speech", code: 200)
    }
    
    func onPartialResult(hyp: Hypothesis?) {
        if hyp != nil {
            delegete.iSphinxPartialResult(partialResult: hyp!.getHypString())
        }
    }
    
    func onResult(hyp: Hypothesis?) {
        if hyp != nil {
            delegete.iSphinxFinalResult(result: hyp!.getHypString(), hypArr: ["a"], scores: [0])
        }
    }
    
    func onError(errorDesc: String) {
        delegete.iSphinxDidStop(reason: errorDesc, code: 500)
    }
    
    func onTimeout() {
        delegete.iSphinxDidStop(reason: "Speech timeout", code: 522)
    }
    
    func onSilent() {
        print("Silent detected!")
    }
}
