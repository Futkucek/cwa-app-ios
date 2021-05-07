////
// 🦠 Corona-Warn-App
//

import XCTest

// swiftlint:disable:next type_body_length
class ENAUITests_09_TraceLocations: XCTestCase {
	
	// MARK: - Setup.
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}
	
	// MARK: - Attributes.
	
	var app: XCUIApplication!
	var screenshotCounter = 0
	let prefix = "traceLocation_"
	
	// MARK: - Test cases.
	
	func test_WHEN_QRCode_is_created_THEN_list_contains_traceLocation() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "Ausser Atem"
		let location = "Cinema Paradiso"
		createTraceLocation(event: event, location: location)
		
		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].exists)
		XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.itemPrefix), event)].exists)
		XCTAssertTrue(app.staticTexts[location].exists)
		
		removeTraceLocation(event: event)
		
		XCTAssertFalse(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.itemPrefix), event)].exists)
		XCTAssertFalse(app.staticTexts[location].exists)
	}
	
	func test_WHEN_list_contains_traceLocations_THEN_delete_all_entries_via_menu_function() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event1 = "Retrospektive"
		let location1 = "Office"
		createTraceLocation(event: event1, location: location1)
		
		let event2 = "Refinement"
		let location2 = "Walldorf"
		createTraceLocation(event: event2, location: location2)
		
		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].exists)
		XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.itemPrefix), event1)].exists)
		XCTAssertTrue(app.staticTexts[location1].exists)
		XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.itemPrefix), event2)].exists)
		XCTAssertTrue(app.staticTexts[location2].exists)
		XCTAssertTrue(app.cells.count >= 3) // assumption: at least 3 cells
		
		// tap the "more" button
		app.navigationBars.buttons[AccessibilityIdentifiers.TraceLocation.Overview.menueButton].tap()
		
		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.editTitle)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.infoTitle)].exists)
		
		// tap "Edit" button
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.editTitle)].tap()
		
		// button "Alle entfernen"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
		
		// Alert: tap "Löschen"
		XCTAssertTrue(app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
		
		XCTAssertTrue(app.cells.count == 1) // assumption: only one cell remains
	}
	
	func test_WHEN_tapCreateQRCode_THEN_traceLocation_input_screen_is_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		// tap button "QR Code erstellen"
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].tap()
		
		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].waitForExistence(timeout: .short))
		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].tap()
		
		XCTAssertTrue(app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder].exists)
		XCTAssertTrue(app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder].exists)
		
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.temporaryDefaultLengthTitleLabel].exists)
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.temporaryDefaultLengthFootnoteLabel].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthTitleLabel].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthFootnoteLabel].exists)
	}
	
	func test_WHEN_traceLocation_is_tapped_THEN_details_of_traceLocation_are_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "At least we can build something"
		let location = "Kino"
		createTraceLocation(event: event, location: location)
		
		XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.itemPrefix), event)].waitForExistence(timeout: .short))
		
		// the QR code cells start at index = 1
		var query = app.cells
		let n = query.count
		XCTAssertTrue(n > 1)
		// tap the cell to display the details
		query.element(boundBy: 1).tap()
		
		// THEN
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitForExistence(timeout: .short)) // identifier defined in xib
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].exists)
		
		// query for the event title and event location
		query = app.cells.staticTexts
		
		let titleLabel = query.element(matching: .staticText, identifier: AccessibilityIdentifiers.TraceLocation.Details.titleLabel)
		XCTAssertNotNil(titleLabel)
		XCTAssertTrue(titleLabel.label == event)
		
		let locationLabel = query.element(matching: .staticText, identifier: AccessibilityIdentifiers.TraceLocation.Details.locationLabel)
		XCTAssertNotNil(locationLabel)
		XCTAssertTrue(locationLabel.label == location)
		
		// close view
		app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].tap()
		// clean up
		removeAllTraceLocationsAtOnce()
	}
	
	func test_WHEN_traceLocation_exists_THEN_checkin_and_checkout() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "Mittagessen"
		let traceLocations: [String: String] = [event: "Kantine"]
		
		createTraceLocation(event: event, location: traceLocations[event] ?? "")
		XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.itemPrefix), event)].waitForExistence(timeout: .short))
		
		// check in
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton].exists)
		app.buttons[AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton].tap()
		
		// THEN
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].exists)
		app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].tap()
		
		removeTraceLocation(event: event)
		
		// switch to "My Checkins" and checkout of the event
		app.tabBars.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		myCheckins_checkout(traceLocations: traceLocations)
		myCheckins_display_details(traceLocations: traceLocations)
		myCheckins_delete_all()
	}

	func test_WHEN_navigate_to_TraceLocations_for_the_first_time_THEN_infoscreen_is_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "NO"])
		
		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		// THEN
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.TraceLocation.imageDescription].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
	}
	
	func test_WHEN_navigate_to_TraceLocations_for_the_second_time_THEN_no_infoscreen_is_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		// THEN
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
	}

	func test_events_in_contact_journal() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "YES"])
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])
		app.launch()
		
		// WHEN

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()

		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .medium))
		let event0 = "Mittagessen"
		let event1 = "Team Meeting"
		let event2 = "Sprint Planung"
		let traceLocations_checked_in: [String: String] = [event0: "Kantine", event1: "Office"]
		let traceLocations_not_checked_in: [String: String] = [event2: "Walldorf"]

		createEventAndCheckin(event0, traceLocations_checked_in)
		createEventAndCheckin(event1, traceLocations_checked_in)
		createTraceLocation(event: event2, location: traceLocations_not_checked_in[event2] ?? "")

		removeAllTraceLocationsAtOnce()

		// MyCheckins: check out of all events
		app.tabBars.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		myCheckins_checkout(traceLocations: traceLocations_checked_in)
		myCheckins_delete_all()
		
		// THEN
		// switch to journal and check entries for events
		app.tabBars.buttons[AccessibilityIdentifiers.Tabbar.diary].tap()
		XCTAssertTrue(app.navigationBars[AccessibilityLabels.localized(AppStrings.ContactDiary.Overview.title)].waitForExistence(timeout: .medium))

		
		// Get the first overview table view cell.
		let overviewCell = app.tables.firstMatch.cells[String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.cell, 0)]
		
		// Check we have two locations
		XCTAssertTrue(overviewCell.staticTexts[String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.location, 0)].waitForExistence(timeout: .short))
		XCTAssertTrue(overviewCell.staticTexts[String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.location, 1)].waitForExistence(timeout: .short))
	}

	func test_WHEN_event_checkout_THEN_display_details() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "YES"])
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		let event1 = "Mittagessen"
		let event2 = "Team Meeting"
		let traceLocations: [String: String] = [event1: "Kantine", event2: "Office"]
		
		createEventAndCheckin(event1, traceLocations)
		createEventAndCheckin(event2, traceLocations)
		removeAllTraceLocationsAtOnce()
		
		// switch to "My Checkins" and checkout of the event
		app.tabBars.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		
		myCheckins_checkout(traceLocations: traceLocations)
		myCheckins_display_details(traceLocations: traceLocations)
		
		XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.Checkins.Overview.itemPrefixCheckedOut), event2)].exists)
		app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.Checkins.Overview.itemPrefixCheckedOut), event2)].tap()
		
		// tap "Speichern" to go back to overview
		let buttons = app.buttons
		XCTAssertTrue(buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).exists)
		buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).tap()
		
		myCheckins_delete_all()
	}

	// MARK: - Screenshots

	func test_screenshots_of_traceLocation_print_flow() throws {
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "NO"])
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "YES"])
		app.launch()
		
		// navigate to "Create QR Code"
		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		XCTAssertTrue(traceLocationsCardButton.waitForExistence(timeout: .extraLong))
		traceLocationsCardButton.tap()
		
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_InfoScreen")
		app.swipeUp()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_InfoScreen")
		app.swipeUp()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_InfoScreen")
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
		
		let event = "Team Meeting"
		let location = "Office"
		createTraceLocation(event: event, location: location, withScreenshots: true)
		
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_traceLocationOverview")
		
		// navigate to detail view for second item
		app.tables[AccessibilityIdentifiers.TraceLocation.Overview.tableView].cells.element(boundBy: 1).tap()
		
		// check if the print version button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_traceLocationDetailScreen")
		
		// navigate to trace location print version view
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
		
		// wait for the pdf view to be loaded
		let delayExpectation = XCTestExpectation()
		delayExpectation.isInverted = true
		wait(for: [delayExpectation], timeout: .short)
		
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_traceLocationPdfScreen")
		
		// navigate back
		let query = app.navigationBars.buttons
		let n = query.count
		XCTAssertTrue(n > 0)
		for i in 0...(n - 1) {
			let label = query.element(boundBy: i).label
			if label == AccessibilityLabels.localized(AppStrings.Common.general_BackButtonTitle) {
				query.element(boundBy: i).tap()
				break
			}
		}
		
		// tap the close button
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].tap()
		
		// check in
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton].tap()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinScreen")
		app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].tap()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_myQRCodes")

		// clean up
		removeAllTraceLocationsAtOnce()
		
		// MyCheckins: check out of all events
		app.tabBars.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		myCheckins_delete_all()

	}

	// MARK: - Private
	
	private func createEventAndCheckin(_ event: String, _ traceLocations_checked_in: [String: String]) {
		createTraceLocation(event: event, location: traceLocations_checked_in[event] ?? "")
		XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.itemPrefix), event)].waitForExistence(timeout: .short))
		// check in
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton].tap()
		app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].tap()
	}
	
	
	// Check out of all events
	private func myCheckins_checkout(traceLocations: [String: String]) {
		
		let initialNumberOfCells = app.cells.count
		
		// iterate over all event cells and count the checkout buttons
		let query = app.cells.buttons
		let n = query.count
		XCTAssertTrue(n > 1)
		var numberOfCheckouts = 0
		for i in 0...(n - 1) {
			if query.element(boundBy: i).identifier == AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton {
				numberOfCheckouts = numberOfCheckouts.inc()
			}
		}
		XCTAssertTrue(numberOfCheckouts == traceLocations.count) // assumption: one cell has a checkout button
		
		// for all events: checkout
		for event in traceLocations.keys {
			XCTAssertTrue(query.element(boundBy: 1).identifier == AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton)
			XCTAssertTrue(query.element(boundBy: 1).waitForExistence(timeout: .short))
			// XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.Checkins.Overview.itemPrefixCheckIn), event)].exists)
			XCTAssertTrue(app.staticTexts[traceLocations[event] ?? ""].exists)
			query.element(boundBy: 1).tap()
		}
		
		XCTAssertTrue(initialNumberOfCells == app.cells.count)
	}
	
	private func myCheckins_display_details(traceLocations: [String: String]) {
		// for all events: display details
		for event in traceLocations.keys {
			XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.Checkins.Overview.itemPrefixCheckedOut), event)].exists)
			XCTAssertTrue(app.staticTexts[traceLocations[event] ?? ""].exists)
			app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.Checkins.Overview.itemPrefixCheckedOut), event)].tap()
			
			let staticTexts = app.cells.staticTexts
			XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.typeLabel).exists)
			XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationTypeLabel).exists)
			XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationDescriptionLabel).exists)
			XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationAddressLabel).exists)
			XCTAssertTrue(app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.Checkins.Overview.itemPrefixCheckedOut), event)].exists)
			XCTAssertTrue(app.staticTexts[traceLocations[event] ?? ""].exists)
			
			// tap "Speichern" to go back to overview
			let buttons = app.buttons
			XCTAssertTrue(buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).exists)
			buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).tap()
		}
	}
	
	private func myCheckins_delete_all() {
		// tap the "more" button
		XCTAssertTrue(app.navigationBars.buttons[AccessibilityIdentifiers.Checkin.Overview.menueButton].waitForExistence(timeout: .short))
		app.navigationBars.buttons[AccessibilityIdentifiers.Checkin.Overview.menueButton].tap()
		
		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.editTitle)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.infoTitle)].exists)
		
		// tap "Edit" button
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.editTitle)].tap()
		
		// button "Alle entfernen"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
		
		// Alert: tap "Entfernen"
		XCTAssertTrue(app.alerts.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.DeleteAllAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		app.alerts.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
		
		XCTAssertTrue(app.cells.count == 1) // assumption: only one cell remains
		
	}
	
	private func createTraceLocation(event: String, location: String) {
		createTraceLocation(event: event, location: location, withScreenshots: false)
	}
	
	private func createTraceLocation(event: String, location: String, withScreenshots: Bool) {
		// add trace location
		if withScreenshots == true { snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_emptyList") }

		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].tap()
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].waitForExistence(timeout: .short))
		if withScreenshots == true { snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_categories") }
		
		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].tap()
		let descriptionInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder]
		let locationInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder]
		descriptionInputField.tap()
		descriptionInputField.typeText(event)
		locationInputField.tap()
		locationInputField.typeText(location)
		if withScreenshots == true { snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_createQRCodeInputScreen") }
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
	}
	
	private func removeTraceLocation(event: String) {
		// swipe left to remove a single trace location
		app.staticTexts[String(format: AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.itemPrefix), event)].swipeLeft()
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		
		// tap "Löschen"
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
		// Alert: tap "Löschen"
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
	}
	
	private func removeAllTraceLocationsAtOnce() {
		// use the "More" button to remove all trace locations
		XCTAssertTrue(app.navigationBars.buttons.element(boundBy: 1).waitForExistence(timeout: .short))
		app.navigationBars.buttons.element(boundBy: 1).tap()
		
		let editButton = app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.editTitle)]
		XCTAssertTrue(editButton.waitForExistence(timeout: .medium))
		editButton.tap()
		
		// tap "Alle entfernen"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
		
		// Alert: tap "Löschen"
		XCTAssertTrue(app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteAllAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteAllAlert.confirmButtonTitle)].tap()
		
		return // all QR codes have been deleted
	}
	
}
