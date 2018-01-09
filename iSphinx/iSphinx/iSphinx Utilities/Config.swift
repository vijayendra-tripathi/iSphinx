//
//  Config.swift
//  TLSphinx
//
//  Created by Bruno Berisso on 5/29/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation
import Sphinx.Base
import Sphinx.Pocket

open class Config {
    
    fileprivate var pointer: OpaquePointer!
    fileprivate var cArgs: [UnsafeMutablePointer<Int8>]!
    
    public init?() {
        let args = [("-hmm", Utilities.getAcousticPath())]
        cArgs = args.flatMap { (name, value) -> [UnsafeMutablePointer<Int8>] in
            return [strdup(name), strdup(value)]
        }
        let count = CInt(cArgs.count)
        cArgs.withUnsafeMutableBytes { (p) -> () in
            let pp = p.baseAddress?.assumingMemoryBound(to: UnsafeMutablePointer<Int8>?.self)
            pointer = cmd_ln_parse_r(nil, ps_args(), count, pp, 1)
        }
        if pointer == nil {
            return nil
        }
    }
    
    public init?(args: (String, String)...) {
        cArgs = args.flatMap { (name, value) -> [UnsafeMutablePointer<Int8>] in
            return [strdup(name),strdup(value)]
        }
        let count = CInt(cArgs.count)
        cArgs.withUnsafeMutableBytes { (p) -> () in
            let pp = p.baseAddress?.assumingMemoryBound(to: UnsafeMutablePointer<Int8>?.self)
            pointer = cmd_ln_parse_r(nil, ps_args(), count, pp, 1)
        }
        if pointer == nil {
            return nil
        }
    }
    
    public init?(fromFile: String) {
        pointer = cmd_ln_parse_file_r(nil, ps_args(), fromFile, 1)
        if pointer == nil {
            return nil
        }
    }
    
    deinit {
        for cString in cArgs {
            free(cString)
        }
        cmd_ln_free_r(pointer)
    }
    
    open func delete() {
        for cString in cArgs {
            free(cString)
        }
        cmd_ln_free_r(pointer)
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    open func setString(key: String, value: String?) {
        cmd_ln_set_str_r(pointer, key, value)
    }
    
    open func getString(key: String) -> String {
        return String.init(cString: cmd_ln_str_r(pointer, key))
    }
    
    open func setFloat(key: String, value: Float) {
        cmd_ln_set_float_r(pointer, key, Double(value))
    }
    
    open func getFloat(key: String) -> Float {
        return Float(cmd_ln_float_r(pointer, key))
    }
    
    open func setInteger(key: String, value: Int) {
        cmd_ln_set_int_r(pointer, key, value)
    }
    
    open func getInteger(key: String) -> Int {
        return cmd_ln_int_r(pointer, key)
    }
    
    open func setBoolean(key: String, value: Bool) {
        if value {
            cmd_ln_set_int_r(pointer, key, 1)
        } else {
            cmd_ln_set_int_r(pointer, key, 0)
        }
    }
    
    open func getBoolean(key: String) -> Bool {
        return cmd_ln_int_r(pointer, key) == 1 ? true : false
    }
}
