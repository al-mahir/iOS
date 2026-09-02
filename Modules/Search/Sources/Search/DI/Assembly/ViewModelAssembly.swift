//
//  ViewModelAssembly.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//

import Swinject

@MainActor
final class ViewModelAssembly: Assembly {
    @MainActor
    func assemble(container: Container) {
        container.register(SearchViewModel.self) { r in
            SearchViewModel(
                searchUseCase: r.resolve(SearchAyahsUseCase.self)!,
                quranRepository: MockQuranRepository(),
                fetchTafsirUseCase: FetchTafsirUseCase(
                    repository: r.resolve(TafsirRepositoryProtocol.self)!
                )
            )
        }
    }
}

