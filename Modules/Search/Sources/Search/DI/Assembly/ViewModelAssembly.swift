//
//  ViewModelAssembly.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//

import Swinject

final class ViewModelAssembly: @MainActor Assembly {
    @MainActor
    func assemble(container: Container) {
        container.register(SearchViewModel.self) { r in
            SearchViewModel(
                searchUseCase: r.resolve(SearchAyahsUseCase.self)!,
                quranRepository: r.resolve(QuranRepositoryProtocol.self) ?? MockQuranRepository()
            )
        }
    }
}
