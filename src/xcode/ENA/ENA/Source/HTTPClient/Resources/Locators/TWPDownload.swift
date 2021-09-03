//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func traceWarningPackageDownload(
		unencrypted: Bool,
		country: String,
		packageId: Int,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let apiVersion = unencrypted ? "v1" : "v2"
		return Locator(
			endpoint: .distribution,
			paths: ["version", apiVersion, "twp", "country", country, "hour", String(packageId)],
			method: .get,
			defaultHeaders: [fake: "cwa-fake"],
			type: .retrying
		)
	}

}
