//
//  SecondClass.swift
//  SourcekittenExample
//
//  Created by Paul Taykalo on 3/6/17.
//  Copyright © 2017 Paul Taykalo. All rights reserved.
//

import Foundation
import UIKit

protocol ProtocolForGeneric {}
protocol ProtocolForGeneric2 {}

class GenericClass<A:ProtocolForGeneric> {}
class GenericClass2<B:ProtocolForGeneric & ProtocolForGeneric2> {}
class GenericClass3<C:ProtocolForGeneric, D:ProtocolForGeneric2> {}


class TheButton: UIButton {}

class GenericClassWithProp<E:ProtocolForGeneric> {
    var item: E
    init(item:E) {
        self.item = item
    }
}

protocol ProtocolWithGenericFunction {
    func genericFunction<F>(item:F) -> F
    func genericFunction2<G:ProtocolForGeneric2>(item:G) -> G
    func genericFunction3<N>(item:N) -> String

}

class ClassWithGenericFunction {
    func genericFunction<J>(item:J) -> J {
        return item
    }
}

extension ClassWithGenericFunction {
    func genericFunctionInExtension<K>(item:K) -> K {
        return item
    }
}


protocol ProtocolWithGenericFunctionToImplement {
    func genericFunctionFromProtocol<L>(item:L) -> L
}
extension ClassWithGenericFunction: ProtocolWithGenericFunctionToImplement {
    func genericFunctionFromProtocol<M>(item:M) -> M {
        return item
    }
}


//MARK - Typealiases
protocol ProtocolForTypeAlias {}

public class ClassWithTypeaLias {
    typealias H = ProtocolForTypeAlias
    var item: (H) -> () = {_ in}
}

public class ClassWithTypeaLiasInFunctionParams {
    typealias I = ProtocolForTypeAlias
    func doSomething(name: I) {}
    func doSomethingElse() -> I? {
        return nil
    }
}

