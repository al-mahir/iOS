//
//  ViewModelAssembly.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Swinject
import Bookmarks

final class ViewModelAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MushafViewModel.self) { r in
            MainActor.assumeIsolated {
                MushafViewModel(
                    getPage: r.resolve(GetMushafPageUseCase.self)!,
                    pageBookmarkUseCase: r.resolve(PageBookmarkUseCase.self)!,
                    surahBookmarkUseCase: r.resolve(SurahBookmarkUseCase.self)!,
                    ayahBookmarkUseCase: r.resolve(AyahBookmarkUseCase.self)!
                )
            }
        }
    }
}
