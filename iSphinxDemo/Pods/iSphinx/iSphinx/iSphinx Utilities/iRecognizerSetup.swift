//
//  iSphinxSetup.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 20/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class iRecognizerSetup {
    
    fileprivate var config: Config!
    
    open static func defaultSetup() -> iRecognizerSetup {
        return iRecognizerSetup(config: Decoder.defaultConfig())
    }
    
    open static func setupFromFile(filePath: String) -> iRecognizerSetup {
        return iRecognizerSetup(config: Decoder.fileConfig(filePath: filePath))
    }
    
    public init(config: Config) {
        self.config = config
    }
    
    open func getRecognizer() -> iRecognizer {
        return iRecognizer(config: self.config)
    }
    
    open func setAcousticModel(aModelPath: String) -> iRecognizerSetup {
        return self.setString(key: "-hmm", value: aModelPath)
    }
    
    open func setDictionary(dicPath: String) -> iRecognizerSetup {
        return self.setString(key: "-dict", value: dicPath)
    }
    
    open func setLanguageModel(lmPath: String) -> iRecognizerSetup {
        return self.setString(key: "-lm", value: lmPath)
    }
    
    open func setSampleRate(sampRate: Int) -> iRecognizerSetup {
        return self.setFloat(key: "-samprate", value: Float(sampRate))
    }
    
    open func setRawLogDir(rawPath: String) -> iRecognizerSetup {
        return self.setString(key: "-rawlogdir", value: rawPath)
    }
    
    open func setKeywordThreshold(thresHold: Float) -> iRecognizerSetup {
        return self.setFloat(key: "-kws_threshold", value: thresHold)
    }
    
    open func setShowDebugInfo(isShow: Bool) -> iRecognizerSetup {
        if isShow {
            return self.setString(key: "-logfn", value: "/dev/null")
        } else {
            return self.setString(key: "-logfn", value: nil)
        }
    }
    
    open func setBoolean(key: String, value: Bool) -> iRecognizerSetup {
        self.config.setBoolean(key: key, value: value)
        return self
    }
    
    open func setInteger(key: String, value: Int) -> iRecognizerSetup {
        self.config.setInteger(key: key, value: value)
        return self
    }
    
    open func setFloat(key: String, value: Float) -> iRecognizerSetup {
        self.config.setFloat(key: key, value: value)
        return self
    }
    
    open func setString(key: String, value: String?) -> iRecognizerSetup {
        self.config.setString(key: key, value: value)
        return self
    }
}
