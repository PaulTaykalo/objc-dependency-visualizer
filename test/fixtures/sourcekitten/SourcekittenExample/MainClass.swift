//
//  MainClass.swift
//  SourcekittenExample
//
//  Created by Paul Taykalo on 3/4/17.
//  Copyright © 2017 Paul Taykalo. All rights reserved.
//

import Foundation

//MARK: Protocols

protocol ProtocolToExtend { }

protocol AwesomeProtocol { }

protocol SubProtocol: AwesomeProtocol {}


// MARK: Classes
class MainClass {}

class Subclass : MainClass {}

class SubclassOfSubclass: Subclass, AwesomeProtocol {}

class SubclassOfMainClass: MainClass, SubProtocol {}


// MARK: Extensions
extension MainClass: ProtocolToExtend { }

// MARK: Structs
struct SimpleStruct { }

struct StructWithProtocols: ProtocolToExtend, AwesomeProtocol { }






