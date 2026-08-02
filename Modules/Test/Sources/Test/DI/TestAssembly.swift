//
//  TestAssembly.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//


import Swinject
import Common

final class TestAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TestRangeResolver?.self) { r in
            guard let wordsDAO = r.resolve(WordsDAO?.self) ?? nil else { return nil }
            return TestRangeResolver(wordsDAO: wordsDAO)
        }

         container.register(TestSetupViewModel?.self) { r in
            guard let resolver = r.resolve(TestRangeResolver?.self) ?? nil else { return nil }
            return TestSetupViewModel(resolver: resolver)
        }
    }
}
