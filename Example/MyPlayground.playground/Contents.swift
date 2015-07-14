//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var bar = [1,2,3]
reflect(bar).summary
reflect(str).summary
bar

//protocol DTTableViewManageable
//{
//    var storage :String! {get set}
//}
//
//extension UITableViewDelegate where Self: DTTableViewManageable
//{
//    var storage :String!
//        {
//        get {
//            return ""
//        }
//        set {
//            print(storage)
//        }
//    }
//    
//    func foo() {
//        print("var")
//    }
//}
//
//class FooViewController: UIViewController, DTTableViewManageable, UITableViewDelegate
//{
//    
//}
//
//class BarViewController : UITableViewController, DTTableViewManageable
//{
//    
//}
//
//
//
//let controller = FooViewController()
//controller.foo()
//
//controller.storage = "bar"
