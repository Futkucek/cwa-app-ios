//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENASecurity

final class GCMEncryptionTests: XCTestCase {

    func test_When_Decrypt_Then_CorrectStringIsReturned() {

        for testData in testDatas {
            guard let key = Data(base64Encoded: testData.keyBase64),
                  let encrypted = Data(base64Encoded: testData.expectedCiphertextBase64),
                let initializationVector = Data(base64Encoded: testData.ivBase64) else {
                XCTFail("Could not create test data.")
                return
            }

            let gcmEncryption = GCMEncryption(
                encryptionKey: key,
                initializationVector: initializationVector
            )

            switch gcmEncryption.decrypt(data: encrypted) {
            case .failure(let error):
                XCTFail("Test failed with error: \(error)")
            case .success(let decryptedData):
                XCTAssertEqual(testData.plaintextUtf8, String(data: decryptedData, encoding: .utf8))
            }
        }
    }

    func test_When_Encrypt_Then_CorrectStringIsReturned() {

        for testData in testDatas {
            guard let key = Data(base64Encoded: testData.keyBase64),
                  let decrypted = Data(base64Encoded: testData.plaintextBase64),
                let initializationVector = Data(base64Encoded: testData.ivBase64) else {
                XCTFail("Could not create test data.")
                return
            }

            let gcmEncryption = GCMEncryption(
                encryptionKey: key,
                initializationVector: initializationVector
            )

            switch gcmEncryption.encrypt(data: decrypted) {
            case .failure(let error):
                XCTFail("Test failed with error: \(error)")
            case .success(let encryptedData):
                XCTAssertEqual(testData.expectedCiphertextBase64, encryptedData.base64EncodedString())
            }
        }
    }

    private struct TestData {
        let keyBase64: String
        let ivBase64: String
        let plaintextBase64: String
        let plaintextUtf8: String
        let expectedCiphertextBase64: String
    }

    private let testDatas = [
        TestData(
            keyBase64: "/h2gu0ls/JTRdTPMFQ2NV/Rb4c/efLG+Y8MJ5nbOBVc=",
            ivBase64: "zzGplm+9wbuRg2uxQdLVAg==",
            plaintextBase64: "SGVsbG8gV29ybGQh",
            plaintextUtf8: "Hello World!",
            expectedCiphertextBase64: "/LvIj79dTOcmXeZz7vrabu1QmbQolRyrGPdVgA=="
        ),
        TestData(
            keyBase64: "M+VfHI5c0R/A0lp63kf7nnmb0JEUppocwYUmZgFkeBc=",
            ivBase64: "UVSg+ehTnE5sYaMsWai6Sw==",
            plaintextBase64: "VGVjaFNwZWNzIGFyZSBncjgh",
            plaintextUtf8: "TechSpecs are gr8!",
            expectedCiphertextBase64: "RUMOQIp8WAY9IknGrlC91ikcboYGrBD9HJd3bfUQ6zDUTA=="
        )
    ]
}
