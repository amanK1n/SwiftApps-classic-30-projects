import UIKit

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


for letter in name {
   print("Gimme a \(letter)!"
}


print("What does that spell? \(name.uppercased())!")
