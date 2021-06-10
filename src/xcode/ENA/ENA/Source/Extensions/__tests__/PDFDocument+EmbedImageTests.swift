////
// 🦠 Corona-Warn-App
//

import XCTest
import PDFKit
@testable import ENA

class PDFDocument_EmbedImageTests: CWATestCase {
	
	// swiftlint:disable force_unwrapping
	/// Not proud of this test, if you have a nicer idea, please go ahead.
    func testEmbedingImageAndText() throws {

		let testBundle = Bundle(for: type(of: self))
		
		let documentURL = testBundle.url(forResource: "qr-code-print-template", withExtension: "pdf")!
			
		let pdfDocument = PDFDocument(url: documentURL)!
				
		let image = UIImage(contentsOfFile: testBundle.path(forResource: "qr-code-to-embed", ofType: "png")!)
		
		let descriptionText = PDFText(text: "Event title <Insert Phun here>", size: 10, color: .black, rect: CGRect(x: 80, y: 510, width: 400, height: 15))
		let adressText = PDFText(text: "Hauptstr 3, 69115 Heidelberg", size: 10, color: .black, rect: CGRect(x: 80, y: 525, width: 400, height: 15))
		
		
		try pdfDocument.embedImageAndText(image: image!, at: CGPoint(x: 100, y: 100), texts: [descriptionText, adressText])
    }
	// swiftlint:enable force_unwrapping

}
