import UIKit
import CoreData


extension UIAlertController {

    func isValidAmount(_ str: String) -> Bool {
        
        if let num = Double(str)
        {
            print("Valid amount input: \(num)")
            return true
        }
        return false
    }

    func isValidName(_ name: String) -> Bool {
        if name != ""
        {
            return true
        }
        return false
    }

    @objc func textDidChangeInLoginAlert() {
        if let name = textFields?[0].text,
            let amount = textFields?[1].text,
            let action = actions.last {
            action.isEnabled = isValidAmount(amount) && isValidName(name)
        }
    }
}

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var swapSortingBtn: UIBarButtonItem!
    
    var sortingMethodKey = "selectedCounter"
    var isAscending = false
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let cellSelColour:UIColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Add Edit button
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    
    @IBAction func sortingOptionHasChanged(_ sender: UIBarButtonItem) {
        
        if sortingMethodKey == "selectedCounter"
        {
            sortingMethodKey = "name"
            isAscending = true
            swapSortingBtn.tintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)

        } else
        {
            sortingMethodKey = "selectedCounter"
            isAscending = false
            swapSortingBtn.tintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        }
        
        self.tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }


    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                print(object.name)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.category = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    //Height of cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Custom cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCategoryCellTableViewCell
                
        let category = fetchedResultsController.object(at: indexPath)
        
        
        let backgroundView = UIView() //could be any view
        backgroundView.backgroundColor = category.colour as! UIColor

        cell.labelCategoryName.text = "\(category.name!)"
        
        
        
        var amountInDouble = Double(category.monthlyBudget!)
        cell.labelBudgetAmount.text = String(format: "£%.02f", amountInDouble)

        
        if let notesLabel = category.notes
        {
            cell.labelNotes.text = notesLabel
        }

        
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = fetchedResultsController.object(at: indexPath)
        category.selectedCounter += 1
    }



    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
        let category = fetchedResultsController.object(at: indexPath)

        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            
            //Create an alert for editing
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            
            //Configure alert input fields
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = category.name
                textField.addTarget(alert, action: #selector(alert.textDidChangeInLoginAlert), for: .editingChanged)
            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "\(category.monthlyBudget!)"
                textField.addTarget(alert, action: #selector(alert.textDidChangeInLoginAlert), for: .editingChanged)

            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = category.notes
            })
            
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
            let loginAction = UIAlertAction(title: "Submit", style: .default) { [unowned self] _ in
                    guard let name = alert.textFields?[0].text,
                          let amount = alert.textFields?[1].text,
                          let notes = alert.textFields?[2].text
                        
                        else { return } // Should never happen

                    // Perform login action
                    category.name = name
                    category.monthlyBudget = NSDecimalNumber(string: amount)
                    category.notes = notes
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                
                }
            
                loginAction.isEnabled = false
                alert.addAction(loginAction)
            self.present(alert, animated: true)

     
        }
        
        
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                // delete the item here
                let context = self.fetchedResultsController.managedObjectContext
                context.delete(self.fetchedResultsController.object(at: indexPath))

                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
                tableView.reloadData()
                
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }
    
    func configureCell(_ cell: UITableViewCell, withCategory category: Category) {
        
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Category> {
        
      
//        if _fetchedResultsController != nil {
//            return _fetchedResultsController!
//        }
        

        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: sortingMethodKey, ascending: isAscending)
        
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withCategory: anObject as! Category)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withCategory: anObject as! Category)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

  

}

