

import UIKit
import CoreData

class CategoryDetailViewController: UIViewController, NSFetchedResultsControllerDelegate {

  
    
    var categoryNotes = ""
    var categoryName = ""
    var categoryBudget:NSDecimalNumber = 0.0
    
    var category:Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
