////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionCheckinTests: CWATestCase {

	func testCheckinTransmissionPreparationFiltersSubmittedCheckins() throws {
		let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let startDate = Date()
		let endDate = Date(timeIntervalSinceNow: 15 * 60)

		let checkins = [
			Checkin.mock(traceLocationId: try XCTUnwrap("0".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true),
			Checkin.mock(traceLocationId: try XCTUnwrap("1".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true),
			Checkin.mock(traceLocationId: try XCTUnwrap("2".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: false),
			Checkin.mock(traceLocationId: try XCTUnwrap("3".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: false),
			Checkin.mock(traceLocationId: try XCTUnwrap("4".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true)
		]

		// process checkins
		let preparedCheckins = service.preparedCheckinsForSubmission(
			checkins: checkins,
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(preparedCheckins.count, 2)

		XCTAssertEqual(preparedCheckins[0].locationID, try XCTUnwrap("2".data(using: .utf8)))
		XCTAssertEqual(preparedCheckins[1].locationID, try XCTUnwrap("3".data(using: .utf8)))
	}

    func testCheckinTransmissionPreparation() throws {
        let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let checkin = Checkin.mock(
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		)

		// process checkins
		let preparedCheckins = service.preparedCheckinsForSubmission(
			checkins: [checkin],
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(preparedCheckins.count, 5)

		XCTAssertEqual(preparedCheckins[0].transmissionRiskLevel, 4)
		XCTAssertEqual(preparedCheckins[1].transmissionRiskLevel, 6)
		XCTAssertEqual(preparedCheckins[2].transmissionRiskLevel, 7)
		XCTAssertEqual(preparedCheckins[3].transmissionRiskLevel, 8)
		XCTAssertEqual(preparedCheckins[4].transmissionRiskLevel, 8)
    }

	func testDerivingWarningTimeInterval() throws {
		let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let startOfToday = Calendar.current.startOfDay(for: Date())

		let filteredStartDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 1, to: startOfToday))
		let filteredEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 8, to: filteredStartDate))

		let keptStartDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 0, to: startOfToday))
		let keptEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 10, to: keptStartDate))
		let derivedEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 20, to: keptStartDate))

		let expectedStartIntervalNumber = UInt32(keptStartDate.timeIntervalSince1970 / 600)
		let expectedEndIntervalNumber = UInt32(derivedEndDate.timeIntervalSince1970 / 600)

		let checkin1 = Checkin.mock(
			checkinStartDate: filteredStartDate,
			checkinEndDate: filteredEndDate
		)
		let checkin2 = Checkin.mock(
			checkinStartDate: keptStartDate,
			checkinEndDate: keptEndDate
		)

		// process checkins
		let preparedCheckins = service.preparedCheckinsForSubmission(
			checkins: [checkin1, checkin2],
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(preparedCheckins.count, 1)

		XCTAssertEqual(preparedCheckins[0].startIntervalNumber, expectedStartIntervalNumber)
		XCTAssertEqual(preparedCheckins[0].endIntervalNumber, expectedEndIntervalNumber)
	}
}
