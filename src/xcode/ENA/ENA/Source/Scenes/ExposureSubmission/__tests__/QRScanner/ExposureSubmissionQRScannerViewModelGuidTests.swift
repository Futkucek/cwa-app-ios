//
// 🦠 Corona-Warn-App
//

import AVFoundation
import Foundation
import XCTest
@testable import ENA

final class ExposureSubmissionQRScannerViewModelGuidTests: CWATestCase {

	private func createViewModel() -> ExposureSubmissionQRScannerViewModel {
		ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })
	}

	func testGIVEN_lowercasedURL_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?123456-12345678-1234-4DA7-B166-B86D85475064") else {
			XCTFail("result cant be nil")
			return
		}

		// THEN
		switch result {
		case .pcr(let guid):
			XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475064", guid)
		case .antigen:
			XCTFail("expected PCR test")
		case .teleTAN:
			XCTFail("expected PCR test")
		}
	}

	func testGIVEN_uppercasedURL_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		guard let result = viewModel.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?123456-12345678-1234-4DA7-B166-B86D85475064") else {
			XCTFail("result cant be nil")
			return
		}

		// THEN
		switch result {
		case .pcr(let guid):
			XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475064", guid)
		case .antigen:
			XCTFail("expected PCR test")
		case .teleTAN:
			XCTFail("expected PCR test")
		}
	}

	func testGIVEN_lowercasedURLWithDoublePathSlashes_WHEN_extractGUID_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "https://localhost//?123456-12345678-1234-4DA7-B166-B86D85475064")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_lowercasedURLWithTripplePathSlashes_WHEN_extractGUID_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "https://localhost///?123456-12345678-1234-4DA7-B166-B86D85475064")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_uppercasedURLWithDoublePathSlashes_WHEN_extractGUID_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST///?123456-12345678-1234-4DA7-B166-B86D85475064")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_lowercasedURLUppercaseGuid_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?123456-12345678-1234-4DA7-B166-B86D85475ABC") else {
			XCTFail("result cant be nil")
			return
		}

		// THEN
		switch result {
		case .pcr(let guid):
			XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475ABC", guid)
		case .antigen:
			XCTFail("expected PCR test")
		case .teleTAN:
			XCTFail("expected PCR test")
		}
	}

	func testGIVEN_lowercasedURLMixedGuid_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?123456-12345678-1234-4DA7-B166-B86D85475abc") else {
			XCTFail("result cant be nil")
			return
		}

		// THEN
		switch result {
		case .pcr(let guid):
			XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475abc", guid)
		case .antigen:
			XCTFail("expected PCR test")
		case .teleTAN:
			XCTFail("expected PCR test")
		}
	}

	func testGIVEN_uppercasedUrlUppercasedGuid_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		guard let result = viewModel.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?123456-12345678-1234-4DA7-B166-B86D85475ABC") else {
			XCTFail("result cant be nil")
			return
		}

		// THEN
		switch result {
		case .pcr(let guid):
			XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475ABC", guid)
		case .antigen:
			XCTFail("expected PCR test")
		case .teleTAN:
			XCTFail("expected PCR test")
		}
	}

	func testGIVEN_uppercasedUrlMixedcaseGuid_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		guard let result = viewModel.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?123456-12345678-1234-4DA7-B166-B86D85475abc") else {
			XCTFail("result cant be nil")
			return
		}

		// THEN
		switch result {
		case .pcr(let guid):
			XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475abc", guid)
		case .antigen:
			XCTFail("expected PCR test")
		case .teleTAN:
			XCTFail("expected PCR test")
		}
	}

	func testGIVEN_missingGuid_WHEN_extractGUID_THEN_isValidGUIDMatches() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_percentescapedSpaceinURL_WHEN_extractGUID_THEN_isValidGUIDMatches() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "https://localhost/%20?3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_otherHost_WHEN_extractGUID_THEN_isINvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "https://some-host.com/?3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_httpSchemeURL_WHEN_extractGUID_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "http://localhost/?123456-12345678-1234-4DA7-B166-B86D85475064")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_urlWithWrongFormattedGuid_WHEN_extractGUID_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_urlWithToShortInvalidGUID_WHEN_extractGUID_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?https://localhost/?4CD1F87D6FDA")

		// THEN
		XCTAssertNil(guid)
	}

	func testGIVEN_wwwLocalhostURL_WHEN_extractGUID_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let guid = viewModel.coronaTestQRCodeInformation(from: "https://www.localhost/%20?3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")

		// THEN
		XCTAssertNil(guid)
	}

}
