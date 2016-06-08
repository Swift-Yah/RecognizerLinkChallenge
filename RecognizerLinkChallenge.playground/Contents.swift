// : Playground - noun: a place where people can play

import UIKit

extension String {
	static var empty: String {
		return String()
	}

	static var whiteSpace: String {
		return " "
	}

	static var dash: String {
		return "-"
	}

	static var slash: String {
		return "/"
	}

	static var urlPattern: String {
		return "https?:\\/\\/([\\w.]+)(\\/[\\w-]*)(\\/[\\w-]+)?(\\/[\\w-]+)?(\\/[\\w-]+)?(\\/[\\w-]+)?(?:[\\/?+][\\w=+]+)?"
	}
}

extension String {
	var range: NSRange {
		return NSRange(location: 0, length: characters.count)
	}

	var normalizedCapture: String {
		return stringByReplacingOccurrencesOfString(.slash, withString: .empty)
	}

	var processedCaptureGroups: [String] {
		guard let regex = try? NSRegularExpression(pattern: .urlPattern, options: NSRegularExpressionOptions.CaseInsensitive),
			match = regex.firstMatchInString(self, options: NSMatchingOptions(), range: self.range) else { return [] }

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
	func wordOnRange(range: NSRange) -> String {
		let nsString = self as NSString

		return nsString.substringWithRange(range)
	}
}

extension NSRange {
	var isNotEmpty: Bool {
		return (location >= 0) && (length > 0)
	}
}

extension NSRange {
	func translate(string: String) -> String {
		return string.wordOnRange(self)
	}
}

struct Item {
	var id: Int
	var title: String
	var price: Double
	var link: String
	var urlsToCheck: [String]
}

extension Item {
    var identifier: String {
        return String(id)
    }
    
	var normalizedTitle: String {
		return title.lowercaseString.stringByReplacingOccurrencesOfString(.whiteSpace, withString: .dash)
	}

	var url: NSURL {
		return NSURL(string: link) ?? NSURL()
	}

	var processedLinkCaptureGroups: [String] {
		return link.processedCaptureGroups
	}
}

extension Item {

	func isProductLink(urlToCompare: String) -> Bool {
		let captureGroups = urlToCompare.processedCaptureGroups

		var equalValues = [String]()

		for c in captureGroups {
			guard processedLinkCaptureGroups.contains(c) else { continue }

			equalValues.append(c)
		}

		guard equalValues.count <= 1 else { return true }
        
        var itensFounded = 0

        for c in captureGroups {
            itensFounded += c.containsString(normalizedTitle) ? 1 : 0
            itensFounded += c.containsString(identifier) ? 1 : 0
        }
        
        return itensFounded >= 2
	}
}

let itemsToTest = [
	Item(id: 16599221, title: "Produto de Teste 1", price: 100.00, link: "http://www.lojadojoao.com.br/p/16599221", urlsToCheck: [
		"http://www.lojadojoao.com.br/produto-de-teste-1-16599221",
		"http://www.lojadojoao.com.br/",
		"http://www.lojadojoao.com.br/categoria-teste",
		"http://www.lojadojoao.com.br/search/helloword",
		"http://www.lojadojoao.com.br/produto-de-teste-1-16599221?utm_teste=testando"
	]),
	Item(id: 12345, title: "Produto Legal", price: 230.00, link: "http://www.lojadamaria.com.br/perfume-the-one-sport-masculino-edt/t/2/campanha_id/+752+", urlsToCheck: [
		"http://www.lojadamaria.com.br/perfume-the-one-sport-masculino-edt?utm_source=ShopBack",
		"http://www.lojadamaria.com.br/search/helloword",
		"http://www.lojadamaria.com.br/categoria-legais",
		"http://www.lojadamaria.com.br/perfume-the-one-sport-masculino-edt"
	]),
	Item(id: 8595, title: "Produto Sem Nome", price: 140.00, link: "http://www.lojadoze.com.br/p/chapeu-caipira-de-palha-desfiado/campanha_id/34", urlsToCheck: [
		"http://www.lojadoze.com.br/chapeu-caipira-de-palha-desfiado",
		"http://www.lojadoze.com.br/home",
		"http://www.lojadoze.com.br/categoria-teste",
		"http://www.lojadoze.com.br/chapeu-caipira-de-palha-desfiado?google"
	])
]

var productLink = 0

for i in itemsToTest {
	for u in i.urlsToCheck {
		let status = i.isProductLink(u) ? "is" : "is not"
		productLink += i.isProductLink(u) ? 1 : 0

		print("Your requested link \(u) \(status) a product link for the base link \(i.link)")
	}
}

let expected = 6
let isFinished = (productLink == expected) ? "yes" : "no"

print("We finished for this mass of tests? \(isFinished) [\(productLink) of \(expected)]")
