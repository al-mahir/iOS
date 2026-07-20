//
//  UseCaseAssembly.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//



import Swinject

final class UseCaseAssembly: Assembly {
   func assemble(container: Container) {
       
       container.register(SearchAyahsUseCase.self) { r in
           SearchAyahsUseCaseImpl(repository: r.resolve(SearchRepository.self)!)
       }
   }
}
