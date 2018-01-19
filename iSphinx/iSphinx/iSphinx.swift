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
    fileprivate var silentToDetect: Float = 1.0
    fileprivate var unSupportedWords: [String] = [String]()
    fileprivate var originalWords: [String] = [String]()
    fileprivate var oovWords: [String] = [String]()
    fileprivate let arpaFile = Utilities.getAssetPath()!.appending("\(SEARCH_ID).arpa")
    fileprivate let fullDictionary = Utilities.getAssetPath()?.appending("\(SEARCH_ID).txt")
    fileprivate let dictPathTemp = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(SEARCH_ID)-dict.txt")
    
    /** Set the delegete from your class. */
    open var delegete: iSphinxDelegete!
    
    public init() {}
    
    /** Start speech recognition without timeout. */
    open func startISphinx() {
        recognizer.startIRecognizer()
    }
    
    /** Start speech recognition with timeout. */
    open func startISphinx(timeoutInSec: Int) {
        recognizer.startIRecognizer(timeoutInSec: timeoutInSec)
    }
    
    /** Prepare iSphinx with default acoustic model and dictionary. You need to set the language model with other method. */
    open func prepareISphinx(onPreExecute: @escaping(_ config: Config) -> (),
                             onPostExecute: @escaping(_ isSuccess: Bool) -> ()) {
        self.unSupportedWords.removeAll()
        self.config = iRecognizerSetup.defaultSetup().getRecognizer().getDecoder().getConfig()
        config.setString(key: "-dict", value: fullDictionary)
        config.setFloat(key: "-samprate", value: 16000)
        config.setFloat(key: "-vad_threshold", value: 3.5);
        config.setFloat(key: "-lw", value: 6.5);
        onPreExecute(config)
        recognizer = iRecognizer(config: config)
        recognizer.setSilentToDetect(seconds: silentToDetect)
        recognizerTemp = iRecognizer(config: config)
        recognizer.delegete = self
        onPostExecute(true)
    }
    
    /** Prepare iSphinx with custom setting. You can add your own language model, acoustic model and dictionary. Set aModelPath or dictFile to nil if you want to use the default file. */
    open func prepareISphinx(lmFile: String, aModelPath: String?, dictFile: String?, onPreExecute: @escaping(_ config: Config) -> (),
                             onPostExecute: @escaping(_ isSuccess: Bool) -> ()) {
        self.unSupportedWords.removeAll()
        self.config = Config(args: ("-hmm", aModelPath == nil ? Utilities.getAcousticPath()! : aModelPath!))
        config.setString(key: "-dict", value: dictFile == nil ? fullDictionary : dictFile)
        config.setString(key: "-lm", value: lmFile)
        config.setFloat(key: "-vad_threshold", value: 3.5);
        config.setFloat(key: "-lw", value: 6.5);
        onPreExecute(config)
        recognizer = iRecognizer(config: config)
        recognizer.setSilentToDetect(seconds: silentToDetect)
        recognizerTemp = iRecognizer(config: config)
        recognizer.delegete = self
        onPostExecute(true)
    }
    
    /** Prepare iSphinx with custom setting. You can add your own acoustic model and dictionary. Set dictFile to nil if you want to use the default file. */
    open func prepareISphinx(aModelPath: String, dictFile: String?, onPreExecute: @escaping(_ config: Config) -> (),
                             onPostExecute: @escaping(_ isSuccess: Bool) -> ()) {
        self.unSupportedWords.removeAll()
        self.config = Config(args: ("-hmm", aModelPath))
        config.setString(key: "-dict", value: dictFile == nil ? fullDictionary : dictFile)
        config.setFloat(key: "-vad_threshold", value: 3.5);
        config.setFloat(key: "-lw", value: 6.5);
        onPreExecute(config)
        recognizer = iRecognizer(config: config)
        recognizer.setSilentToDetect(seconds: silentToDetect)
        recognizerTemp = iRecognizer(config: config)
        recognizer.delegete = self
        onPostExecute(true)
    }
    
    fileprivate func generateDictionary(words: [String]) {
        var text = ""
        for word in words {
            if let lookup = recognizerTemp.getDecoder().lookupWord(word: word.lowercased()) {
                text += "\(word.lowercased()) \(lookup)\n"
            } else {
                unSupportedWords.append(word)
            }
        }
        try? text.write(to: dictPathTemp!, atomically: true, encoding: .utf8)
        recognizer.getDecoder().loadDict(dictFile: dictPathTemp!.path, fFilter: nil, format: "dict")
        delegete.iSphinxUnsupportedWords(words: unSupportedWords)
    }
    
    fileprivate func generateNGramModel(words: [String]) {
        nGramModel = NGramModel(config: config, logMath: recognizer.getDecoder().getLogMath(), lmFile: arpaFile)
        for word in words {
            nGramModel?.addWord(word: word.lowercased(), weight: 1.7)
        }
        recognizer.getDecoder().setLanguageModel(name: SEARCH_ID, nGramModel: nGramModel!)
    }
    
    fileprivate func generateGrammar(words: [String]) {
        var grammarStr = ""
        for word in words {
            grammarStr += "\(word) "
        }
        recognizer.getDecoder().setJsgfString(name: SEARCH_ID, gramStr: grammarStr)
    }
    
    /** Get the dictionary path with words from array string. */
    open func getDictionary(words: [String]) -> String {
        var text = ""
        let dictPath = dictPathTemp!.absoluteString.replacingOccurrences(of: "file://", with: "")
        for word in words {
            if let lookup = recognizerTemp.getDecoder().lookupWord(word: word.lowercased()) {
                text += "\(word.lowercased()) \(lookup)\n"
            } else {
                unSupportedWords.append(word)
            }
        }
        try? text.write(to: dictPathTemp!, atomically: true, encoding: .utf8)
        print("Unsupported words: \(unSupportedWords.description)")
        return dictPath
    }
    
    /** Get the language model path with words from array string. */
    open func getNGramModel(words: [String]) -> NGramModel {
        let nGramModel = NGramModel(config: config, logMath: recognizer.getDecoder().getLogMath(), lmFile: arpaFile)
        for word in words {
            nGramModel.addWord(word: word.lowercased(), weight: 1.7)
        }
        return nGramModel
    }
    
    /** Update language model from a string. oovWords is word disturber so if the user says a word from oovWords the hypothesis will be ???. This function will repleace old language model already set. */
    open func updateVocabulary(text: String, oovWords: [String], completion: @escaping() -> ()) {
        self.originalWords = Utilities.removePunctuation(words: text).components(separatedBy: " ").removeDuplicates()
        self.oovWords = oovWords.removeDuplicates()
        Utilities.removePunctuationArr(words: &self.oovWords)
        var words: [String] = [String]()
        words.append(contentsOf: self.originalWords)
        words.append(contentsOf: self.oovWords)
        self.generateDictionary(words: words.removeDuplicates())
        self.generateNGramModel(words: words.removeDuplicates())
        completion()
    }
    
    /** Update language model from an array string. oovWords is word disturber so if the user says a word from oovWords the hypothesis will be ???. This function will repleace old language model already set. */
    open func updateVocabulary(words: [String], oovWords: [String], completion: @escaping() -> ()) {
        self.originalWords = words.removeDuplicates()
        self.oovWords = oovWords.removeDuplicates()
        Utilities.removePunctuationArr(words: &self.originalWords)
        Utilities.removePunctuationArr(words: &self.oovWords)
        var words: [String] = [String]()
        words.append(contentsOf: self.originalWords)
        words.append(contentsOf: self.oovWords)
        self.generateDictionary(words: words.removeDuplicates())
        self.generateNGramModel(words: words.removeDuplicates())
        completion()
    }
    
    /** Update JSGF grammar from a string. oogWords is word disturber so if the user says a word from oogWords the hypothesis will be ???. This function will repleace old JSGF grammar already set. */
    open func updateGrammar(text: String, oogWords: [String], completion: @escaping() -> ()) {
        self.originalWords = Utilities.removePunctuation(words: text).components(separatedBy: " ").removeDuplicates()
        self.oovWords = oogWords.removeDuplicates()
        Utilities.removePunctuationArr(words: &self.oovWords)
        var words: [String] = [String]()
        words.append(contentsOf: self.originalWords)
        words.append(contentsOf: self.oovWords)
        self.generateDictionary(words: words.removeDuplicates())
        self.generateGrammar(words: words.removeDuplicates())
        completion()
    }
    
    /** Update JSGF grammar from a file. Set nil the dictFile if you sure already set the dictionary before. This function will repleace old JSGF grammar already set. */
    open func updateGrammar(file: String, dictFile: String?, completion: @escaping() -> ()) {
        if dictFile != nil {
            if FileManager.default.fileExists(atPath: dictFile!) {
                recognizer.getDecoder().loadDict(dictFile: dictFile!, fFilter: nil, format: "dict")
            } else {
                print("\(String(describing: dictFile)) doesn't exist.")
            }
        }
        recognizer.getDecoder().setJsgfFile(name: SEARCH_ID, filePath: file)
        completion()
    }
    
    /** Update language model from a file. Set nil the dictFile if you sure already set the dictionary before. This function will repleace old language model already set. */
    open func updateLanguageModel(file: String, dictFile: String?, completion: @escaping() -> ()) {
        if dictFile != nil {
            if FileManager.default.fileExists(atPath: dictFile!) {
                recognizer.getDecoder().loadDict(dictFile: dictFile!, fFilter: nil, format: "dict")
            } else {
                print("\(String(describing: dictFile)) doesn't exist.")
            }
        }
        recognizer.getDecoder().setLanguageModelFile(name: SEARCH_ID, lmPath: file)
        completion()
    }
    
    /** Get the decoder. */
    open func getDecoder() -> Decoder {
        return recognizer.getDecoder()
    }
    
    /** Get the recognizer class. */
    open func getRecognizer() -> iRecognizer {
        return recognizer
    }
    
    /** Get the recorder class. You can control audio record from this class. */
    open func getRecorder() -> iSphinxRecorder {
        return recognizer.getISphinxRecorder()
    }
    
    /** Set the silent to detect in seconds. Silent to detect is delaying before speech considered as silent. */
    open func setSilentToDetect(seconds: Float) {
        self.silentToDetect = seconds
    }
    
    /** Get the silent to detect in seconds. */
    open func getSilentToDetect() -> Float {
        return silentToDetect
    }
    
    func onBeginningOfSpeech() {
        delegete.iSphinxDidSpeechDetected()
    }
    
    func onEndOfSpeech() {
        recognizer.stopSpeech()
        delegete.iSphinxDidStop(reason: "End of speech!", code: 200)
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
                var hypArr: [String] = [String]()
                var scores: [Double] = [Double]()
                var hypStr: String = ""
                let segIterator = recognizer.getDecoder().getSegmentIterator()
                while segIterator.hasNext() {
                    let segment = segIterator.next()
                    let score = recognizer.getDecoder().getLogMath().score(prob: segment.getProb())
                    if (!segment.getWord().contains("<") && !segment.getWord().contains(">") &&
                        !segment.getWord().contains("[") && !segment.getWord().contains("]")) {
                        if originalWords.contains(segment.getWord()) {
                            hypStr += segment.getWord() + " ";
                        } else {
                            hypStr += "??? ";
                        }
                        scores.append(score)
                        hypArr.append(segment.getWord())
                    }
                }
                delegete.iSphinxFinalResult(result: hypStr.trimmingCharacters(in: .whitespacesAndNewlines), hypArr: hypArr, scores: scores)
            }
        }
    }
    
    func onError(errorDesc: String) {
        recognizer.stopSpeech()
        delegete.iSphinxDidStop(reason: errorDesc, code: 500)
    }
    
    func onTimeout() {
        recognizer.stopSpeech()
        delegete.iSphinxDidStop(reason: "Speech timeout!", code: 522)
    }
}
