//
//  SheikhDetailViewModel.swift
//  Sheikh
//

import Foundation
import Combine
import AVFoundation
import Swinject

public enum SheikhTab: String, CaseIterable, Identifiable {
    case about
    case packages
    case reviews

    public var id: String { rawValue }

    public var titleEn: String {
        switch self {
        case .about: return "About"
        case .packages: return "Packages"
        case .reviews: return "Reviews"
        }
    }

    public var titleAr: String {
        switch self {
        case .about: return "عن المعلم"
        case .packages: return "الباقات"
        case .reviews: return "التقييمات"
        }
    }
}

@MainActor
public final class SheikhDetailViewModel: ObservableObject {

    @Published public var sheikh: Sheikh? = nil
    @Published public var selectedTab: SheikhTab = .about
    @Published public var playingSampleID: String? = nil
    @Published public var isPlayingAudio: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var selectedPackage: SheikhPackage? = nil
    @Published public var showPackageSelectedToast: Bool = false

    private let sheikhID: String
    private let getSheikhDetailUseCase: any GetSheikhDetailUseCaseProtocol
    private let toggleFavoriteUseCase: any ToggleFavoriteSheikhUseCaseProtocol

    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()

    public init(
        sheikhID: String,
        prefetched: Sheikh? = nil,
        getSheikhDetailUseCase: (any GetSheikhDetailUseCaseProtocol)? = nil,
        toggleFavoriteUseCase: (any ToggleFavoriteSheikhUseCaseProtocol)? = nil
    ) {
        self.sheikhID = sheikhID
        self.getSheikhDetailUseCase = getSheikhDetailUseCase ?? SheikhDIContainer.shared.container.resolve((any GetSheikhDetailUseCaseProtocol).self)!
        self.toggleFavoriteUseCase = toggleFavoriteUseCase ?? SheikhDIContainer.shared.container.resolve((any ToggleFavoriteSheikhUseCaseProtocol).self)!
        self.sheikh = prefetched
    }

    deinit {
        player?.pause()
        player = nil
    }

    public func loadDetail() {
        if sheikh == nil {
            fetchDetail()
        }
    }

    public func refresh() {
        fetchDetail()
    }

    public func toggleFavorite() {
        guard var current = sheikh else { return }
        current.isFavorite.toggle()
        self.sheikh = current

        toggleFavoriteUseCase.execute(id: sheikhID)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] isFav in
                self?.sheikh?.isFavorite = isFav
            }
            .store(in: &cancellables)
    }

    public func toggleAudioSample(_ sample: SheikhAudioSample) {
        configureAudioSession()
        if playingSampleID == sample.id {
            if isPlayingAudio {
                player?.pause()
                isPlayingAudio = false
            } else {
                player?.play()
                isPlayingAudio = true
            }
        } else {
            player?.pause()
            playingSampleID = sample.id
            if let url = URL(string: sample.audioUrl) {
                let playerItem = AVPlayerItem(url: url)
                player = AVPlayer(playerItem: playerItem)
                player?.playImmediately(atRate: 1.0)
                isPlayingAudio = true

                NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] _ in
                        self?.stopAudio()
                    }
                    .store(in: &cancellables)
            }
        }
    }

    public func stopAudio() {
        player?.pause()
        isPlayingAudio = false
        playingSampleID = nil
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    public func selectPackage(_ package: SheikhPackage) {
        selectedPackage = package
        showPackageSelectedToast = true
    }

    private func fetchDetail() {
        isLoading = true
        errorMessage = nil

        getSheikhDetailUseCase.execute(id: sheikhID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] sheikh in
                self?.sheikh = sheikh
            }
            .store(in: &cancellables)
    }
}
