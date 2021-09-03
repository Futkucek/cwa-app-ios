//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func dccRegisterPublicKey(
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let forceApiHeader = String(forceApiTokenHeader ? 1 : 0)
		return Locator(
			endpoint: .dcc,
			paths: ["version", "v1", "publicKey"],
			method: .post,
			defaultHeaders: [fake: "cwa-fake", forceApiHeader: "cwa-ppac-ios-accept-api-token", String.getRandomString(of: 14): "cwa-header-padding"],
			// TODO: Body (Protobuf) is missing here
			type: .default
		)
	}

}
