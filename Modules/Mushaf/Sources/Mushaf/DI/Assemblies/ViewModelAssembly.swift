//
//  ViewModelAssembly.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Swinject

final class ViewModelAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MushafViewModel.self) { r in
         
            MainActor.assumeIsolated {
                MushafViewModel(getPage: r.resolve(GetMushafPageUseCase.self)!)
            }
        }
    }
}
