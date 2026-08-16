import XCTest
@testable import Listening

final class ListeningTests: XCTestCase {

    @MainActor
    func testDownloadedSurahModel() throws {
        let surah = DownloadedSurah(
            reciterId: 7,
            reciterName: "Mishary Rashid Alafasy",
            reciterArabicName: "مشاري راشد العفاسي",
            surahNumber: 1,
            surahName: "Al-Fatihah",
            fileSize: 1_048_576, // 1 MB
            audioFileName: "surah_1.mp3",
            timingsFileName: "surah_1_timings.json"
        )

        XCTAssertEqual(surah.id, "7_1")
        XCTAssertEqual(surah.reciterId, 7)
        XCTAssertEqual(surah.surahNumber, 1)
        XCTAssertFalse(surah.formattedSize.isEmpty)
    }

    @MainActor
    func testSurahDataHelper() throws {
        XCTAssertEqual(SurahData.englishName(for: 1), "Al-Fatihah")
        XCTAssertEqual(SurahData.englishName(for: 36), "Ya-Sin")
        XCTAssertEqual(SurahData.englishName(for: 114), "An-Nas")
        XCTAssertEqual(SurahData.arabicName(for: 1), "الفاتحة")
    }

    @MainActor
    func testListeningViewModelSurahNavigation() throws {
        let audioManager = AudioSyncManager()
        let fetchReciters = FetchRecitersUseCaseMock()
        let fetchWordTimings = FetchWordTimingsUseCaseMock()
        let fetchAudioURL = FetchAudioURLUseCaseMock()

        let vm = ListeningViewModel(
            audioManager: audioManager,
            fetchReciters: fetchReciters,
            fetchWordTimings: fetchWordTimings,
            fetchAudioURL: fetchAudioURL
        )

        vm.activateListeningMode(surahNumber: 36, surahName: "Ya-Sin", startAyah: 1)
        XCTAssertEqual(vm.currentChapterNumber, 36)

        vm.nextSurah()
        XCTAssertEqual(vm.currentChapterNumber, 37)

        vm.previousSurah()
        XCTAssertEqual(vm.currentChapterNumber, 36)
    }
}

// MARK: - Mocks for Testing

private struct FetchRecitersUseCaseMock: FetchRecitersUseCase {
    func execute() -> Combine.AnyPublisher<[Reciter], NetworkKit.NetworkError> {
        Combine.Just([])
            .setFailureType(to: NetworkKit.NetworkError.self)
            .eraseToAnyPublisher()
    }
}

private struct FetchWordTimingsUseCaseMock: FetchWordTimingsUseCase {
    func execute(reciterId: Int, chapterNumber: Int) -> Combine.AnyPublisher<[WordTiming], NetworkKit.NetworkError> {
        Combine.Just([])
            .setFailureType(to: NetworkKit.NetworkError.self)
            .eraseToAnyPublisher()
    }
}

private struct FetchAudioURLUseCaseMock: FetchAudioURLUseCase {
    func execute(reciterId: Int, chapterNumber: Int) -> Combine.AnyPublisher<URL, NetworkKit.NetworkError> {
        Combine.Just(URL(string: "https://example.com/audio.mp3")!)
            .setFailureType(to: NetworkKit.NetworkError.self)
            .eraseToAnyPublisher()
    }
}
