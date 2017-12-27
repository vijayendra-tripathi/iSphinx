//
//  Hypothesis.swift
//  TLSphinx
//
//  Created by Bruno Berisso on 6/1/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation

open class Hypothesis {
    
    fileprivate var decoder: Decoder!
    fileprivate var hypString: String = ""
    fileprivate var bestScore: CInt = 0
    
    internal init(decoder: Decoder, isFinal: Bool) {
        self.decoder = decoder
        if isFinal {
            hypString = String.init(describing: ps_get_hyp_final(decoder.getPointer(), &bestScore))
        } else {
            hypString = String.init(cString: ps_get_hyp(decoder.getPointer(), &bestScore))
        }
    }
    
    open func getFinalHypotesis() {
    }
    
    open func getHypString() -> String {
        return hypString
    }
    
    open func getBestScore() -> Int {
        return Int(bestScore)
    }
    
    open func getProb() -> Int {
        return Int(ps_get_prob(decoder.getPointer()))
    }
}

//public struct Hypothesis {
//    public let text: String
//    public let score: Int
//}

//extension Hypothesis : CustomStringConvertible {
//    public var description: String {
//        get {
//            return "Text: \(text) - Score: \(score)"
//        }
//    }
//}

//func +(lhs: Hypothesis, rhs: Hypothesis) -> Hypothesis {
//    return Hypothesis(text: lhs.text + " " + rhs.text, score: (lhs.score + rhs.score) / 2)
//}
//
//func +(lhs: Hypothesis?, rhs: Hypothesis?) -> Hypothesis? {
//    if let _lhs = lhs, let _rhs = rhs {
//        return _lhs + _rhs
//    } else {
//        if let _lhs = lhs {
//            return _lhs
//        } else {
//            return rhs
//        }
//    }
//}

