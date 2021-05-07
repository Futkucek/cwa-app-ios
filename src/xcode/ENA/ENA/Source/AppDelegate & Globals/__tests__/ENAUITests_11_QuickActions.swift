////
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_11_QuickActions: XCTestCase {

	private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
	private lazy var cwaBundleDisplayName = { XCUIApplication().label }() // "Corona-Warn"
	/// The translated label string as we can't (?) use any identifiers there
	private lazy var newDiaryEntryLabel = XCUIApplication().localized(AppStrings.QuickActions.contactDiaryNewEntry)
	private lazy var eventCheckinLabel = XCUIApplication().localized(AppStrings.QuickActions.eventCheckin)

    override func setUpWithError() throws {
        continueAfterFailure = false

		// Clear potentially broken states by pressing the home button
		// Yes kids, your fancy device once had a button to bring you back to the dashboard ;)
		XCUIDevice.shared.press(.home)
    }

	override func tearDownWithError() throws {
		XCUIDevice.shared.press(.home)
	}

	/// Test shortcut state after a fresh installtation
	///
	/// This test is INTENTIONALLY disabled in the normal test plan as it might affect the execution of other tests
	/// (in the current test/fastlane configuration)
    func testLaunchViaShortcutFromFreshInstall() throws {
		try uninstallCWAppIfPresent()

		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertFalse(appIcon.isHittable)

		// fresh installation
		let app = try installCWApp()
		// validate; onboarding first screen?
		XCTAssertTrue(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: .long))

		// Shortcuts should not be available on 'fresh' installations which aren't onboarded
		try checkAppMenu(expectNewDiaryItem: false, expectEventCheckin: false)
    }

	func testLaunchAfterOnboarding_diaryInfoRequred() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "NO"]) // first launch of the contact diary
		app.launch()

		// On home screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .medium))

		let quickAction = try checkAppMenu(expectNewDiaryItem: true)
		quickAction.tap()

		// we expect the info screen
		XCTAssertFalse(app.segmentedControls[AccessibilityIdentifiers.ContactDiary.segmentedControl].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts["AppStrings.ContactDiaryInformation.descriptionTitle"].exists)
	}

	func testLaunchAfterOnboarding_diaryInfoPassed() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"]) // contact diary info stuff shown and accepted
		app.launch()

		// On home screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .medium))
		let quickAction = try checkAppMenu(expectNewDiaryItem: true)
		quickAction.tap()

		XCTAssertTrue(app.segmentedControls[AccessibilityIdentifiers.ContactDiary.segmentedControl].waitForExistence(timeout: .short))
	}

	func testShortcutAvailabilityDuringSubmissionFlow() throws {
		let app = XCUIApplication()
		app.setDefaults()

		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-testResultResponse", TestResult.positive.stringValue])
		app.launch()

		// Open Intro screen ("Testergebnis abrufen")
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

		// TAN
		let tanButton = app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
		XCTAssertTrue(tanButton.waitForExistence(timeout: .medium))
		tanButton.tap()

		// Fill in dummy TAN.
		
		let tanSubmityButton = app.buttons["AppStrings.ExposureSubmission.primaryButton"]
		XCTAssertTrue(tanSubmityButton.waitForExistence(timeout: .medium))

		"qwdzxcsrhe".forEach {
			app.keyboards.keys[String($0)].tap()
		}
		try checkAppMenu(expectNewDiaryItem: true, expectEventCheckin: true)
		// Submit TAN
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		// remember: TAN tests are ALWAYS positive!

		// Result Screen
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		try checkAppMenu(expectNewDiaryItem: false, expectEventCheckin: false) // !!! Quick action should be disabled until we leave the submission flow

		// We currently back out of the submission flow. This might be extended in future, feel free to add tests for the following views :)
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()

		// don't warn
		app.alerts.firstMatch.buttons[AccessibilityIdentifiers.General.defaultButton].tap()

		// Back on home screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .medium))
		try checkAppMenu(expectNewDiaryItem: true, expectEventCheckin: true) // available again?
	}


	/// Checks the state of the quick action menu according to given parameter.
	///
	/// Once we have a 3rd parameter, we should find a better solution than simply adding plain arguments.
	/// - Parameter expectNewDiaryItem: The desired state wether the 'new diary entry; menu item is existing or not.
	/// - Parameter expectEventCheckin: The desired state wether the 'event checkin' menu item is existing or not.
	/// - Throws: All the funny test errors you might encounter when assertions are not met
	private func checkAppMenu(expectNewDiaryItem: Bool, expectEventCheckin: Bool) throws {
		// to dashboard
		XCUIDevice.shared.press(.home)

		// check app menu
		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertTrue(appIcon.waitForExistence(timeout: .short))
		if !appIcon.isHittable {
			springboard.swipeLeft()
		}
		XCTAssertTrue(appIcon.isHittable)
		appIcon.press(forDuration: 1.5)

		let diaryEntryButton = springboard.buttons[newDiaryEntryLabel]
		if expectNewDiaryItem {
			XCTAssertTrue(diaryEntryButton.exists, "Shortcuts should be available in this state of the submission flow")
		} else {
			XCTAssertFalse(diaryEntryButton.exists, "Shortcuts should not be available once the user is in submission flow")
		}

		let eventCheckinButton = springboard.buttons[eventCheckinLabel]
		if expectEventCheckin {
			XCTAssertTrue(eventCheckinButton.exists, "Shortcuts should be available in this state of the submission flow")
		} else {
			XCTAssertFalse(eventCheckinButton.exists, "Shortcuts should not be available once the user is in submission flow")
		}

		// discard menu and return to app w/o quick action
		XCUIDevice.shared.press(.home)
		// reference to `appIcon` fails for unknown reasons
		springboard.icons[cwaBundleDisplayName].tap()
	}
	
	@discardableResult
	private func checkAppMenu(expectNewDiaryItem: Bool) throws -> XCUIElement {
		// to dashboard
		XCUIDevice.shared.press(.home)

		// check app menu
		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertTrue(appIcon.waitForExistence(timeout: .short))
		if !appIcon.isHittable {
			springboard.swipeLeft()
		}
		XCTAssertTrue(appIcon.isHittable)
		appIcon.press(forDuration: 1.5)

		let diaryEntryButton = springboard.buttons[newDiaryEntryLabel]
		if expectNewDiaryItem {
			XCTAssertNoThrow(diaryEntryButton.exists, "Shortcuts should be available in this state of the submission flow")
		} else {
			XCTAssertThrowsError(diaryEntryButton.exists, "Shortcuts should not be available once the user is in submission flow")
		}
		return diaryEntryButton
	}

	// MARK: - Install/Uninstall our app

	/// Uninstalling the app manually, if present.
	private func uninstallCWAppIfPresent() throws {
		let appIcon = springboard.icons[cwaBundleDisplayName]
		guard appIcon.waitForExistence(timeout: .medium) else { return }
		while !appIcon.isHittable {
			springboard.swipeLeft()
		}
		appIcon.press(forDuration: 1.5)

		// 1. action menu
		springboard.collectionViews.firstMatch.buttons.lastMatch.tap()

		// 2. `„Corona-Warn“ entfernen?` alert
		let firstAlert = springboard.alerts.firstMatch
		XCTAssertTrue(firstAlert.waitForExistence(timeout: .short))
		firstAlert.buttons.firstMatch.tap()

		// 3. `„Corona-Warn“ löschen?` alert
		let finalAlert = springboard.alerts.firstMatch
		XCTAssertTrue(finalAlert.waitForExistence(timeout: .short))
		finalAlert.buttons.lastMatch.tap()
	}

	/// Installs the host app and terminates it right after launch to simulate a (nearly) 'fresh' installation
	///
	/// Because the app still starts shortly, our AppDelegate code runs. Keep this in mind if you encounter some edge cases!
	private func installCWApp() throws -> XCUIApplication {
		let app = XCUIApplication()
		app.launch()
		XCTAssertEqual(app.state, XCUIApplication.State.runningForeground)
		XCUIDevice.shared.press(.home)
		return app
	}
}
