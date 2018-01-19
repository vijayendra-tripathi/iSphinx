# iSphinx
[![Creator](https://img.shields.io/badge/creator-icaksama-green.svg)](https://www.linkedin.com/in/icaksama/)
[![Travis](https://img.shields.io/travis/icaksama/iSphinx.svg)](https://travis-ci.org/icaksama/iSphinx)
[![GitHub license](https://img.shields.io/github/license/icaksama/iSphinx.svg)](https://raw.githubusercontent.com/icaksama/iSphinx/master/LICENSE)
[![Code Size](https://img.shields.io/github/languages/code-size/icaksama/iSphinx.svg)](https://img.shields.io/github/languages/code-size/icaksama/iSphinx.svg)
[![Pod Version](https://img.shields.io/cocoapods/v/iSphinx.svg)](https://img.shields.io/cocoapods/v/iSphinx.svg)
[![Platform](https://img.shields.io/cocoapods/p/iSphinx.svg)](https://img.shields.io/cocoapods/p/iSphinx.svg)
[![Download Total](https://img.shields.io/cocoapods/dt/iSphinx.svg)](https://img.shields.io/cocoapods/dt/iSphinx.svg)
<br>
iOS library for offline speech recognition base on Pocketsphinx engine. Add speech recognition feature into your iOS app with Cocoapods. iSphinx gives simple configuration and implementation for your app without dealing with Pocketsphinx assets and configuration.

## Features
- [x] Support swift 4 and iOS 9 above
- [x] High accuracy
- [x] Build dictionary on the fly
- [x] Build language model (Arpa File) on the fly
- [x] Build JSGF Grammar on the fly
- [x] Support PCM Recorder 16bits / mono little endian (wav file)
- [x] Scoring system every single word (range 0.0 - 1.0)
- [x] Detect unsupported words
- [x] Rejecting Out-Of-Vocabulary (OOV) based on keyword spotting
- [x] Speaker Adaptation (in progress)
- [x] SIMPLE TO USE & FAST!

## Preview
I have tried to speak in different word order:
<p align="center">
<img width="350" src="https://github.com/icaksama/iSphinx/blob/master/iSphinxPreview.gif?raw=true">
</p>

## Cocoapods
Add to `Podfile` :
```text
pod 'iSphinx', '~> 1.1.5'
```

# How to Use

## Add Request Permissions
- Add request permission for recording in your `Info.plist`

## Add The Listener
First, impletent the iSphinxDelegete in your class/ViewController :
```swift
import iSphinx

class ViewController: UIViewController, iSphinxDelegete {
    var isphinx: iSphinx = iSphinx()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isphinx.delegete = self
    }
}
```
iSphinxDelegete have some methods must be implement in your class/ViewController :
```swift
func iSphinxDidStop(reason: String, code: Int) {
    if code == 500 { // 500 code for error
        print(reason)
    } else if code == 522 { // 522 code for timed out
        print(reason)
    } else if code == 200 { // 200 code for finish speech
        print(reason)
    }
}

func iSphinxFinalResult(result: String, hypArr: [String], scores: [Double]) {
    print("Full Result : \(result)")
    // NOTE :
    // [x] parameter "result" : Give final response with ??? values when word out-of-vocabulary.
    // [x] parameter "hypArr" : Give final response in original words without ??? values.

    // Get score from every single word. hypArr length equal with scores length
    for score in scores {
        print(score)
    }

    // Get array word
    for word in hypArr {
        print(word)
    }
}

func iSphinxPartialResult(partialResult: String) {
    print(partialResult)
}

func iSphinxUnsupportedWords(words: [String]) {
    var unsupportedWords = ""
    for word in words {
        unsupportedWords += word + ", "
    }
    print("Unsupported words : \(unsupportedWords)")
}

func iSphinxDidSpeechDetected() {
    print("Speech detected!")
}
```

## Prepare Speech Recognition
You need to prepare speech recognition before use that. You can add new parameters in onPreExecute to increase accuracy or performance.
```swift
isphinx.prepareISphinx(onPreExecute: { (config) in
    // You can add new parameter pocketshinx here
    self.isphinx.setSilentToDetect(seconds: 2)
    config.setString(key: "-parameter", value: "value")
}) { (isSuccess) in
    if isSuccess {
        print("Preparation success!")
    }
}
```

## Update Language Model / Grammar
You can update the vocabulary with language model or JSGF Grammar on the fly. Make sure to remove the punctuation before update vocabulary/grammar. Default punctuation will be remove in iSphinx are `(.), (,) ,(?), (!), (_), (-), (\), (:)`
```swift
// Update vocabulary with language model from single string
isphinx.updateVocabulary(text: "YOUR VOCABULARIES!", oovWords: ["WORDS DISTRUBER", ...]) {
    print("Vocabulary updated!")
}

// Update vocabulary with language model from array string
isphinx.updateVocabulary(text: "YOUR VOCABULARIES!", oovWords: ["WORDS DISTRUBER", ...]) {
    print("Vocabulary updated!")
}

// Update vocabulary with JSGF Grammar from string
isphinx.updateGrammar(text: "YOUR GRAMMAR", oogWords: ["WORDS DISTRUBER", ...]) {
    print("Grammar updated!")
}
```

## Start The Speech Recognition
```swift
// Set the Timeout in seconds
isphinx.startISphinx(timeoutInSec: 10)
```

## Play Audio Record
Make sure play the audio record after speech recognizer is done.
```swift
isphinx.getRecorder().play {
    print("Play audio finish!")
}
```

### Note : Please take a look at iSphinxDemo for detail usage.

## MIT License
```text
Copyright (c) 2018 Saiful Irham Wicaksana

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
