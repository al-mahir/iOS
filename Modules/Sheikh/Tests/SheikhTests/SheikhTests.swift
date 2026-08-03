import XCTest
import Combine
@testable import Sheikh

final class SheikhTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testGetSheikhsUseCaseReturnsSheikhs() throws {
        let repo = SheikhRepositoryImpl()
        let useCase = GetSheikhsUseCase(repository: repo)
        let expectation = XCTestExpectation(description: "Fetch sheikhs")

        useCase.execute()
            .sink { completion in
                if case .failure(let err) = completion {
                    XCTFail("Failed with error: \(err)")
                }
            } receiveValue: { sheikhs in
                XCTAssertFalse(sheikhs.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3.0)
    }

    func testGetSheikhDetailUseCaseReturnsDetailedSheikh() throws {
        let repo = SheikhRepositoryImpl()
        let useCase = GetSheikhDetailUseCase(repository: repo)
        let expectation = XCTestExpectation(description: "Fetch sheikh detail")

        useCase.execute(id: "00000000-0000-0000-0000-000000000000")
            .sink { completion in
                if case .failure(let err) = completion {
                    XCTFail("Failed with error: \(err)")
                }
            } receiveValue: { sheikh in
                XCTAssertEqual(sheikh.firstName, "Sheikh Ahmed")
                XCTAssertEqual(sheikh.lastName, "Karimi")
                XCTAssertTrue(sheikh.hasVerifiedIjazah)
                XCTAssertFalse(sheikh.packages.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3.0)
    }

    @MainActor
    func testSheikhDetailViewModelTabsAndFavorite() throws {
        let repo = SheikhRepositoryImpl()
        let getDetailUseCase = GetSheikhDetailUseCase(repository: repo)
        let toggleFavUseCase = ToggleFavoriteSheikhUseCase(repository: repo)

        let vm = SheikhDetailViewModel(
            sheikhID: "00000000-0000-0000-0000-000000000000",
            prefetched: nil,
            getSheikhDetailUseCase: getDetailUseCase,
            toggleFavoriteUseCase: toggleFavUseCase
        )

        XCTAssertEqual(vm.selectedTab, .about)
        vm.selectedTab = .packages
        XCTAssertEqual(vm.selectedTab, .packages)
        vm.selectedTab = .reviews
        XCTAssertEqual(vm.selectedTab, .reviews)

        let initialFav = vm.sheikh?.isFavorite ?? false
        vm.toggleFavorite()
        XCTAssertNotEqual(vm.sheikh?.isFavorite, initialFav)
    }
}
