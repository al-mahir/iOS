import XCTest
@testable import Authentication

final class AuthenticationTests: XCTestCase {
    func testPublicAuthEndpointsDoNotRequireAuthentication() {
        XCTAssertFalse(AuthEndpoints.login(email: "user@example.com", password: "password").requiresAuthentication)
        XCTAssertFalse(AuthEndpoints.register(
            username: "user",
            firstName: "First",
            lastName: "Last",
            gender: "MALE",
            email: "user@example.com",
            password: "password",
            confirmPassword: "password",
            phoneNumber: "01012345678"
        ).requiresAuthentication)
        XCTAssertFalse(AuthEndpoints.googleSignIn(idToken: "token").requiresAuthentication)
    }

    func testProtectedAuthEndpointsRequireAuthentication() {
        XCTAssertTrue(AuthEndpoints.me(accessToken: "token").requiresAuthentication)
        XCTAssertTrue(AuthEndpoints.logout(accessToken: "token").requiresAuthentication)
    }
}
