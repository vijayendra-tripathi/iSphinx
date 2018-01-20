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
    
    /** Get the default setup of iSphinx. This function will let you get the setup without init decoder and config class. */
    open static func defaultSetup() -> iRecognizerSetup {
        return iRecognizerSetup(config: Decoder.defaultConfig())
    }
    
    /** Get the setup from file config. This function will let you get the setup without init decoder and config class. */
    open static func setupFromFile(filePath: String) -> iRecognizerSetup {
        return iRecognizerSetup(config: Decoder.fileConfig(filePath: filePath))
    }
    
    /** Init setup with config. */
    public init(config: Config) {
        self.config = config
    }
    
    /** Get the recognizer class. */
    open func getRecognizer() -> iRecognizer {
        return iRecognizer(config: self.config)
    }
    
    /** Set the acoustic model. */
    open func setAcousticModel(aModelPath: String) -> iRecognizerSetup {
        return self.setString(key: "-hmm", value: aModelPath)
    }
    
    /** Set the dictionary. */
    open func setDictionary(dicPath: String) -> iRecognizerSetup {
        return self.setString(key: "-dict", value: dicPath)
    }
    
    /** Set the language model. */
    open func setLanguageModel(lmPath: String) -> iRecognizerSetup {
        return self.setString(key: "-lm", value: lmPath)
    }
    
    /** Set the sample rate. Sample rate must be 8000hz or 16000hz with single channel. Default sample rate is 16000hz. */
    open func setSampleRate(sampRate: Int) -> iRecognizerSetup {
        return self.setFloat(key: "-samprate", value: Float(sampRate))
    }
    
    /** Set raw log directory. */
    open func setRawLogDir(rawPath: String) -> iRecognizerSetup {
        return self.setString(key: "-rawlogdir", value: rawPath)
    }
    
    /** Set keyword threshold. */
    open func setKeywordThreshold(thresHold: Float) -> iRecognizerSetup {
        return self.setFloat(key: "-kws_threshold", value: thresHold)
    }
    
    /** Show or hide debug info. */
    open func setShowDebugInfo(isShow: Bool) -> iRecognizerSetup {
        if isShow {
            return self.setString(key: "-logfn", value: "/dev/null")
        } else {
            return self.setString(key: "-logfn", value: nil)
        }
    }
    
    /** Set parameter with boolen value. */
    open func setBoolean(key: String, value: Bool) -> iRecognizerSetup {
        self.config.setBoolean(key: key, value: value)
        return self
    }
    
    /** Set parameter with integer value. */
    open func setInteger(key: String, value: Int) -> iRecognizerSetup {
        self.config.setInteger(key: key, value: value)
        return self
    }
    
    /** Set parameter with float value. */
    open func setFloat(key: String, value: Float) -> iRecognizerSetup {
        self.config.setFloat(key: key, value: value)
        return self
    }
    
    /** Set parameter with string value. */
    open func setString(key: String, value: String?) -> iRecognizerSetup {
        self.config.setString(key: key, value: value)
        return self
    }
}
