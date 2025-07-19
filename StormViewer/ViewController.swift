//
//  ViewController.swift
//  StormViewer
//
//  Created by Sayed on 17/07/25.
//

import UIKit

class ViewController: UITableViewController {
var pic = [String]()
 
    @IBOutlet public var picTableView: UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true

        self.tableView?.separatorStyle = .singleLine
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if item.hasPrefix("nssl") {
                // this is a picture to load!
                pic.append(item)
            }
        }
        print(pic)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return pic.count
   }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = self.pic[indexPath.row]
        return cell
   }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.selectedImage = pic[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

