import UIKit
// PART-1
let name = "Aman"

let letter = name[name.index(name.startIndex, offsetBy: 1)]
print(letter)


extension String {
    subscript(i: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: i)])
    }
    
}
let l2 = name[3]
print(l2)


//for letter in name {
//   print("Gimme a \(letter)!"
//}

// PART-2
let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
            return String(self.dropFirst(prefix.count))
        
    }
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}
let x = password.deletingPrefix("12")
print(x)
let y = password.deletingSuffix("45")
print(y)

extension String {
    var capitalizedFirstLetter: String {
        guard let firstLetter = self.first else { return self }
        return firstLetter.uppercased() + self.dropFirst()
    }
}
let greeting = "hello hoho shgsdh kgjkg"
let capitalizedGreeting = greeting.capitalizedFirstLetter
print(capitalizedGreeting)

let input = "Swift is like Objective-C without the C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

extension String {
    func isMyWordPresent(array: [String]) -> Bool {
        for word in array {
            if self.contains(word) {
                return true
            }
        }
        return false
    }
}
let a = languages.isMyWordPresent(array: languages)
print(a)

