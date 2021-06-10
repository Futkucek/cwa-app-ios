//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_03_Settings: CWATestCase {
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
	}

	func test_0030_SettingsFlow() throws {
		app.launch()
		
		app.swipeUp(velocity: .fast)

		app.cells["AppStrings.Home.settingsCardTitle"].waitAndTap()
		
		XCTAssertTrue(app.cells["AppStrings.Settings.tracingLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.notificationLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.resetLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.Datadonation.description"].waitForExistence(timeout: 5.0))
	}

	func test_0031_SettingsFlow_BackgroundAppRefresh() throws {
		app.launch()
		
		app.swipeUp(velocity: .fast)

		app.cells["AppStrings.Home.settingsCardTitle"].waitAndTap()
		
		app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitAndTap()
		
		XCTAssertTrue(app.images["AppStrings.Settings.backgroundAppRefreshImageDescription"].waitForExistence(timeout: 5.0))
	}
}
