// : Playground - noun: a place where people can play

import UIKit

let start = NSDate()

extension Array where Element: Item {
	/// Process a list of ```Item``` to check it each one is a valid product link.
	/// - Returns: The number of founded valid product link.
	static func processItems(items: [Element], seeLogs: Bool) -> Int {
		var count = 0

		for i in items {
			for u in i.urlsToCheck {
				let status = i.isProductLink(u) ? "~" : "<>"

				count += i.isProductLink(u) ? 1 : 0

				guard seeLogs else { continue }

				print("\(u) \n\t \(status) \(i.link)\n")
			}
		}

		return count
	}
}

extension NSRange {
	/// Checks whether an ```NSRange``` value is not empty, when it is valid, location and length values are different of zero.
	var isNotEmpty: Bool {
		return (location >= 0) && (length > 0)
	}
}

extension NSRange {
	/// Translate the range in a substring inside the ```string``` input.
	func translate(string: String) -> String {
		return string.substringOnRange(self)
	}
}

extension String {
	/// An alias for a empty string.
	static var empty: String {
		return String()
	}

	/// An alias for a white space string.
	static var whiteSpace: String {
		return " "
	}

	/// An alias for a dash string.
	static var dash: String {
		return "-"
	}

	/// An alias for a slash string.
	static var slash: String {
		return "/"
	}

	/// The pattern for an regular expression that matches with an url and separate each slash value inside an capture group.
	static var urlPattern: String {
		return "https?:\\/\\/([\\w.]+)(\\/[\\w-]*)(\\/[\\w-]+)?(\\/[\\w-]+)?(\\/[\\w-]+)?(\\/[\\w-]+)?(?:[\\/?+][\\w=+]+)?"
	}
}

extension String {
	/// Get the total range of a string.
	var range: NSRange {
		return NSRange(location: 0, length: characters.count)
	}

	/// Remove all slash caracters.
	var normalizedCapture: String {
		return stringByReplacingOccurrencesOfString(.slash, withString: .empty)
	}

	/// Process a given string to check whether it match of our ```urlPattern```.
	/// - Returns: An list with all value captured when matched with our regex.
	var processedCaptureGroups: [String] {
		guard let regex = try? NSRegularExpression(pattern: .urlPattern, options: NSRegularExpressionOptions.CaseInsensitive),
			match = regex.firstMatchInString(self, options: NSMatchingOptions(), range: self.range) else { return [] }

		// When i = 0, the captured group is equal the original input string.
		var i = 1
		var captureGroups = [String]()

		while match.rangeAtIndex(i).isNotEmpty {
			let newElement = match.rangeAtIndex(i).translate(self).normalizedCapture

			captureGroups.append(newElement)
			i += 1
		}

		return captureGroups
	}
}

extension String {
	/// Get the substring in a given range value.
	/// - Returns: The substring located in the inputed ```range```.
	func substringOnRange(range: NSRange) -> String {
		let nsString = self as NSString

		return nsString.substringWithRange(range)
	}
}

protocol Item {
	/// Id of an product.
	var id: Int { get }

	/// Description for an product.
	var title: String { get }

	/// Price of an product.
	var price: Double { get }

	/// Link that for this product in our databases.
	var link: String { get }

	/// URLs requested to be checked whether they are products.
	var urlsToCheck: [String] { get }

	/// Checks whether a given url matches with a product url registered in our databases.
	func isProductLink(urlToCompare: String) -> Bool

	/// Run the process logic to checks whether in a given list of ```Item``` an ```expected``` number of product link was found.
	/// - Returns: A message to be showed for the user.
	static func run(items: [Self], expected: Int, seeLogs: Bool) -> String
}

/// The basic amount of data to conceive an product item.
struct ProductItem: Item {
	var id: Int
	var title: String
	var price: Double
	var link: String
	var urlsToCheck: [String]

	func isProductLink(urlToCompare: String) -> Bool {
		let captureGroup = urlToCompare.processedCaptureGroups

		return isValidCaptureGroup(captureGroup)
	}

	static func run(items: [ProductItem], expected: Int, seeLogs: Bool = false) -> String {
		let count = Array.processItems(items, seeLogs: seeLogs)
		let isFinished = (count == expected) ? "yes" : "no"

		return "We finished for this mass of tests? \(isFinished) [\(count) of \(expected)]"
	}
}

extension ProductItem {
	/// An alias of product id but as string.
	var identifier: String {
		return String(id)
	}

	/// The lowercased string and replaced white spaces for dashes.
	var normalizedTitle: String {
		return title.lowercaseString.stringByReplacingOccurrencesOfString(.whiteSpace, withString: .dash)
	}

	/// All capture groups for our product link.
	var processedLinkCaptureGroups: [String] {
		return link.processedCaptureGroups
	}
}

private extension ProductItem {
	/// Check a capture group based in the number of value that it matches with our ```processedLinkCaptureGroups````.
	func hasMinimumEqualValues(captureGroup: [String]) -> Bool {
		var equalValues = [String]()

		for c in captureGroup {
			guard processedLinkCaptureGroups.contains(c) else { continue }

			equalValues.append(c)
		}

		return (equalValues.count > 1)
	}

	/// Search in each string of the capture groups a string that matches with the ```normalizedTitle``` or ```identifier``` values.
	func hasMinimumItemsFounded(captureGroup: [String]) -> Bool {
		var itensFounded = 0

		for c in captureGroup {
			itensFounded += c.containsString(normalizedTitle) ? 1 : 0
			itensFounded += c.containsString(identifier) ? 1 : 0
		}

		return (itensFounded >= 2)
	}

	/// Check a given capture group to check whether it is valid for a product link.
	func isValidCaptureGroup(captureGroup: [String]) -> Bool {
		guard !hasMinimumEqualValues(captureGroup) else { return true }

		return hasMinimumItemsFounded(captureGroup)
	}
}

// MARK: Main

let itemsToTest = [
	ProductItem(id: 16599221, title: "Produto de Teste 1", price: 100.00, link: "http://www.lojadojoao.com.br/p/16599221", urlsToCheck: [
		"http://www.lojadojoao.com.br/produto-de-teste-1-16599221",
		"http://www.lojadojoao.com.br/",
		"http://www.lojadojoao.com.br/categoria-teste",
		"http://www.lojadojoao.com.br/search/helloword",
		"http://www.lojadojoao.com.br/produto-de-teste-1-16599221?utm_teste=testando"
	]),
	ProductItem(id: 12345, title: "Produto Legal", price: 230.00, link: "http://www.lojadamaria.com.br/perfume-the-one-sport-masculino-edt/t/2/campanha_id/+752+", urlsToCheck: [
		"http://www.lojadamaria.com.br/perfume-the-one-sport-masculino-edt?utm_source=ShopBack",
		"http://www.lojadamaria.com.br/search/helloword",
		"http://www.lojadamaria.com.br/categoria-legais",
		"http://www.lojadamaria.com.br/perfume-the-one-sport-masculino-edt"
	]),
	ProductItem(id: 8595, title: "Produto Sem Nome", price: 140.00, link: "http://www.lojadoze.com.br/p/chapeu-caipira-de-palha-desfiado/campanha_id/34", urlsToCheck: [
		"http://www.lojadoze.com.br/chapeu-caipira-de-palha-desfiado",
		"http://www.lojadoze.com.br/home",
		"http://www.lojadoze.com.br/categoria-teste",
		"http://www.lojadoze.com.br/chapeu-caipira-de-palha-desfiado?google"
	])
]

let result = ProductItem.run(itemsToTest, expected: 6, seeLogs: true)

print(result)

let end = NSDate()

let total = end.timeIntervalSinceDate(start)

print("All process occured in \(total) seconds.")
