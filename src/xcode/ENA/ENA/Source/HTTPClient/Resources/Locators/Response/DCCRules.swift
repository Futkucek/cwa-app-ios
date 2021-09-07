//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func DCCRules(
		rulePath: String,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", rulePath],
			method: .get,
			defaultHeaders: [fake: "cwa-fake", String.getRandomString(of: 14): "cwa-header-padding"],
			type: .caching
		)
	}

}
