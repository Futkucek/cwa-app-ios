//
// 🦠 Corona-Warn-App
//

import XCTest
import PDFKit
@testable import ENA

class FileScannerCoordinatorViewModelTests: CWATestCase {

	// MARK: - Helpers

	// based on the nice work of ray wenderlich
	// https://www.raywenderlich.com/4023941-creating-a-pdf-in-swift-with-pdfkit#toc-anchor-002
	private func pdfDocument(password: String? = nil) throws -> PDFDocument {
		let pdfMetaData: [CFString: Any]
		if let password = password {
			pdfMetaData = [
				kCGPDFContextCreator: "DummyData PDF",
				kCGPDFContextAuthor: "Kai Teuber",
				kCGPDFContextOwnerPassword: password,
				kCGPDFContextUserPassword: password
			]
		} else {
			pdfMetaData = [
				kCGPDFContextCreator: "DummyData PDF",
				kCGPDFContextAuthor: "Kai Teuber"
			]
		}

		let format = UIGraphicsPDFRendererFormat()
		format.documentInfo = pdfMetaData as [String: Any]

		let pageWidth = 8.5 * 72.0
		let pageHeight = 11 * 72.0
		let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

		let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
		let data = renderer.pdfData { context in
			context.beginPage()
			let attributes = [
				NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 72)
			]
			let text = "This is a dummy PDF file"
			text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
		}
		return try XCTUnwrap(PDFDocument(data: data))
	}

	private var fakeImage: UIImage = {
		guard let image = UIImage.with(color: .red) else {
			XCTFail("Failed to create a dummy image")
			return UIImage()
		}
		return image
	}()

	// MARK: - UIDocumentPicker

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PickImageWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scan(fakeImage)

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PickImageWithoutQRCode_THEN_Error() throws {
		// GIVEN
		let expectation = expectation(description: "no qr code found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake(),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFailed = { error in
			if case .noQRCodeFound = error {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scan(fakeImage)

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedFileWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		// WHEN
		let pdfDocument = try pdfDocument()
		viewModel.scan(pdfDocument)

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PasswordProtectedPDFFileWithoutQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "no qr code found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake(),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFailed = { error in
			if case .noQRCodeFound = error {
				expectation.fulfill()
			}
		}

		viewModel.missingPasswordForPDF = { password in
			password("12345")
		}

		// WHEN
		let pdfDocument = try pdfDocument(password: "12345")
		viewModel.unlockAndScan(pdfDocument)

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PasswordProtectedPDFFileButWrongPasswordIsGicen_THEN_ResultIsAnError() throws {
		// GIVEN
		let expectation = expectation(description: "no qr code found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake(),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFailed = { error in
			if case .passwordInput = error {
				expectation.fulfill()
			}
		}

		viewModel.missingPasswordForPDF = { password in
			password("123456")
		}

		// WHEN
		let pdfDocument = try pdfDocument(password: "12345")
		viewModel.unlockAndScan(pdfDocument)

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PasswordProtectedPDFFileWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		viewModel.missingPasswordForPDF = { password in
			password("123456")
		}

		// WHEN
		let pdfDocument = try pdfDocument(password: "123456")
		viewModel.unlockAndScan(pdfDocument)

		// THEN
		waitForExpectations(timeout: .short)
	}

	// MARK: UIImagePicker

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedImageWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scan(fakeImage)

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedImageWithoutQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "no qr code found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake(),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFailed = { error in
			if case .noQRCodeFound = error {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scan(fakeImage)

		// THEN
		waitForExpectations(timeout: .short)
	}

	// MARK: PHPicker

	@available(iOS 14, *)
	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedPhotoPickerWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scan(fakeImage)

		// THEN
		waitForExpectations(timeout: .short)
	}

}
