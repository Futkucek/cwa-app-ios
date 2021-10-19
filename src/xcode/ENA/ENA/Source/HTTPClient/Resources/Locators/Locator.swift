//
// 🦠 Corona-Warn-App
//


/**
The locator describes where (endpoint and path) a resource should be send or received. I can also add some headers, like the fake request header.
*/
struct Locator: Hashable {

	// MARK: - Init

	init(
		endpoint: Endpoint,
		paths: [String],
		method: HTTP.Method,
		defaultHeaders: [String: String] = [:]
	) {
		self.endpoint = endpoint
		self.paths = paths
		self.method = method
		self.headers = defaultHeaders
	}

	// MARK: Protocol Hashable

	func hash(into hasher: inout Hasher) {
		hasher.combine(endpoint)
		hasher.combine(paths)
		hasher.combine(method)
	}

	// MARK: - Internal

	let endpoint: Endpoint
	let paths: [String]
	let method: HTTP.Method
	let headers: [String: String]
}
