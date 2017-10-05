//
//  FileWithStructs.swift
//  SourcekittenWithComplexDependencies
//
//  Created by Paul Taykalo on 10/5/17.
//  Copyright © 2017 Paul Taykalo. All rights reserved.
//

import Foundation
protocol ProtocolForStructs {}

struct StructWithoutProtocols { }
struct StructWithProtocol: ProtocolForStructs {}

struct StructWithOtherStructs {
    let a: StructWithoutProtocols
    let b: StructWithProtocol
}
