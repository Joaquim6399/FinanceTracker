import UIKit
import CoreData

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
    
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}

extension UIColor {
    static func getColour(_ num: Int) -> UIColor {
        switch num {
        case 0:
            return UIColor(
                red:   1.0,
                green: 0.0,
                blue:  0.0,
               alpha: 0.4
            )
        case 1:
            return UIColor(
                red:   0.0,
                green: 1.0,
                blue:  0.0,
               alpha: 0.4
            )
        case 2:
            return UIColor(
                red:   0.0,
                green: 0.0,
                blue:  1.0,
               alpha: 0.4
            )
        default:
            return UIColor(
                red:   1.0,
                green: 1.0,
                blue:  0.0,
               alpha: 0.4
            )
        }
        
        
    }
}



class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var labelTestSpent: UILabel!
    
    @IBOutlet weak var labelRemaining: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    let cellSelColour:UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1)
    
    
    @IBOutlet var pieChartLabels: [UILabel]!
    
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.category != nil)
        {
            let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
        else
        {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.category != nil)
        {
            return self.fetchedResultsController.sections?.count ?? 1
        }
        else
        {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as! CustomExpenseCellTableViewCell
        
        //configureCell(cell, indexPath: indexPath)
        //Use configure later
        
    
            if (self.category != nil)
            {
                
                let amount = self.fetchedResultsController.fetchedObjects?[indexPath.row].amount
                let expenseAmount = Double(amount!)
                let notes = self.fetchedResultsController.fetchedObjects?[indexPath.row].notes
                let date = self.fetchedResultsController.fetchedObjects?[indexPath.row].date
                let occurrence = self.fetchedResultsController.fetchedObjects?[indexPath.row].occurrence
                //cell.labelExpenseNotesAndAmount.text = "\(notes!) £\(expenseAmount)"
                cell.labelExpenseNotesAndAmount.text = String(format: "\(notes!) £%.02f", expenseAmount)
                //Date
                let formatter1 = DateFormatter()
                formatter1.dateStyle = .short
                cell.labelExpenseDate.text = "\(formatter1.string(from: date!))"
                
                var categoryBudget = self.category?.monthlyBudget
                var categoryBudgetInDouble = Double(categoryBudget!)
                cell.expenseProgress.progress = Float(expenseAmount/categoryBudgetInDouble)
            
                cell.labelOccurence.text = "\(occurrence!)"
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.getColour(indexPath.row)
                cell.selectedBackgroundView = backgroundView
                
                
            }
        
        
        
        
        return cell
    }
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let category = category {
            detailDescriptionLabel.text = category.name
            
            //labelTestSpent.text
            changeTotalSpentLabel()
            //renderPieChart()
            }
       }
    
    
    
    let calendar = NSCalendar.current
    
    func calculateExpenses(object: Expense) -> Double{
        
        let currentDate = Date()
        var expenseValue:Double = Double(object.amount!)
        
        //calculate Date Difference
        let dateDifference = calendar.numberOfDaysBetween(object.date!, and: currentDate)
        print("\tDate difference: \(dateDifference)")

        var newExpenseValue = expenseValue
        
        //if date difference not greater than one, the expense only starts counting from the day foward the expense was set
        if dateDifference != 0
        {
            for _ in 1 ... abs(dateDifference)
            {
                newExpenseValue += expenseValue
            }
        }
      
        
        return newExpenseValue
    }
    
    func changeTotalSpentLabel() {
        
        var totalExpenses:Double = 0.0

        var remaining:Double = 0.0
        
        if self.category != nil
        {
            for expenses in self.fetchedResultsController.fetchedObjects!
            {
                var expenseAmount = Double(expenses.amount!)
                
                
                switch expenses.occurrence {
                case "OneOff":
                    print("Oneoff Expense")
                    totalExpenses += expenseAmount
                    
                case "Daily":
                    totalExpenses += calculateExpenses(object: expenses)
                    
                case "Weekly":
                    let currentDate = Date()
                    let dateDifference = calendar.numberOfDaysBetween(expenses.date!, and: currentDate)
                    
                    var expenseValue:Double = Double(expenses.amount!)

                    var newExpenseValue = expenseValue
                    
                    if dateDifference != 0
                    {
                        for _ in 1 ... abs(getNumberOfWeeks(dateDifference))
                        {
                            newExpenseValue += expenseValue
                        }
                    }
                    
                    
                    totalExpenses += newExpenseValue
                case "Monthly":
                    let currentDate = Date()
                    let dateDifference = calendar.numberOfDaysBetween(expenses.date!, and: currentDate)
                    
                    var expenseValue:Double = Double(expenses.amount!)

                    var newExpenseValue = expenseValue
                    
                    if dateDifference != 0
                    {
                        if getNumberOfMonths(dateDifference) != 0
                        {
                            for _ in 1 ... abs(getNumberOfMonths(dateDifference))
                            {
                                newExpenseValue += expenseValue
                            }
                        }
                        
                    }
                    
                    
                    totalExpenses += newExpenseValue
                default:
                    break
                }
            }
            
            
            var _monthlyBudget = Double(category!.monthlyBudget!)
            
            remaining = _monthlyBudget - totalExpenses
        }
        
        labelTestSpent.text = String(format: "Spent: £%.02f", totalExpenses)
        
        labelRemaining.text = String(format: "Remaining: £%.02f", remaining)
    }
    
    func getNumberOfWeeks(_ num: Int) -> Int
    {
        let result:Double = Double(num) / 7.0
        
        let number = Int(result)
        
        return number
        
    }
    
    func getNumberOfMonths(_ num: Int) -> Int
    {
        let result:Double = Double(num) / 30.0
        
        let number = Int(result)
        
        return number
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        labelTestSpent.text = ""
        labelRemaining.text = ""
        configureView()
        
        
        //Pie Chart
        renderPieChart()
        
        
        
        
    }

    var category: Category?
    
    var pieChartView = PieChartView()
    
    func renderPieChart()
    {
        if self.category != nil
        {
            pieChartView.frame = CGRect(x: -100, y: 100, width: view.frame.size.width, height: 200)
            view.addSubview(setValuesPieChart(pieChartView))
        }
    }
    
    func setValuesPieChart(_ pieChart: PieChartView) -> PieChartView
    {
        var remainingAmountOfExpenses = 0.0
        
        pieChart.segments.removeAll()
        
        for(index, item) in self.fetchedResultsController.fetchedObjects!.enumerated()
        {
            //self.fetchedResultsController.fetchedObjects!
            if(index < 3)
            {
                let amount = item.amount!
                pieChart.segments.append(Segment(color: .getColour(index), value: CGFloat(amount)))
                
                let amountInDouble = Double(amount)
                pieChartLabels[index].text = String(format: "\(item.notes!): £%.02f", amountInDouble)
                pieChartLabels[index].backgroundColor = .getColour(index)
                
            }
            
            if(index >= 3)
            {
                for _ in 3 ... self.fetchedResultsController.fetchedObjects!.count
                {
                    let amount = item.amount
                    remainingAmountOfExpenses += Double(amount!)
                    pieChart.segments.append(Segment(color: .getColour(index), value: CGFloat(remainingAmountOfExpenses)))
                }
                
                //Add the amount when the problem is fixed
                pieChartLabels[3].text = ("Remaining")
                pieChartLabels[3].backgroundColor = .getColour(4)
                break
            }
            

        }
        
        
        return pieChart
    }
    // MARK: - Fetched results controller
    var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Expense>
    {
        if _fetchedResultsController != nil
        {
            return _fetchedResultsController!
        }
        //build the fetch requewst here
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "amount", ascending: false, selector: #selector(NSDecimalNumber.compare(_:)))

        
        //add the sort request
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //add the predicate
        let predicate = NSPredicate(format: "categoryTarget = %@", self.category!)
        fetchRequest.predicate = predicate
        
        //initiate our result controller
        let aFetchedResultsController = NSFetchedResultsController<Expense>(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: #keyPath(Expense.category),
            cacheName: nil)
        //Study cache just in case is important
        
        //set the delegate
        aFetchedResultsController.delegate = self
        
        _fetchedResultsController = aFetchedResultsController
        
        //perform the fetch
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
        
    }
    // MARK: - Configure the cell
    //Gets called everytime a cell needs to be rendered
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        //We might wanna do selection of the first item of the category list
        //Can be a if let here
        if (self.category != nil)
        {
            //We can use notes or amount attribute, choose one
            //Trying to find the bug
            let amount = self.fetchedResultsController.fetchedObjects?[indexPath.row].amount
            //let notes = self.fetchedResultsController.fetchedObjects?[indexPath.row].notes
            
            let expenseAmount = Double(amount!)
            

            cell.textLabel?.text = String(describing: amount!)
            //cell.textLabel?.text = notes
            
            
            cell.backgroundColor = self.cellSelColour
            //notes can be optional so check this more carefully
            if let notesText = self.fetchedResultsController.fetchedObjects?[indexPath.row].notes
            {
            cell.detailTextLabel?.text = notesText
             }
            else {
             cell.detailTextLabel!.text = ""
             }
        }
        
    }
    
    

    //MARK: - table editing - fetchresultcontroller delegate funcs
    
     func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
        let expense = fetchedResultsController.object(at: indexPath)

                                      //used to be .default
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            
            //Create an alert for editing
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            
            //Configure alert input fields
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = expense.notes
                textField.addTarget(alert, action: #selector(alert.textDidChangeInLoginAlert), for: .editingChanged)
            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "\(expense.amount!)"
                textField.addTarget(alert, action: #selector(alert.textDidChangeInLoginAlert), for: .editingChanged)

            })
            
            
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
            let loginAction = UIAlertAction(title: "Submit", style: .default) { [unowned self] _ in
                    guard let notes = alert.textFields?[0].text,
                          let amount = alert.textFields?[1].text
                        
                        else { return } // Should never happen

                    //Perform login action
                expense.notes = notes
                expense.amount = NSDecimalNumber(string: amount)
            
                
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
     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        //Lets try this one and see if it captures every change
        changeTotalSpentLabel()
        
        view.addSubview(setValuesPieChart(pieChartView))
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
          switch type {
          case .insert:
              self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
          case .delete:
             self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
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
      self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
             case .move:
                 tableView.moveRow(at: indexPath!, to: newIndexPath!)
             default:
                 return
         }
     }
    
   
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let identifer = segue.identifier
        {
            switch identifer {
            case "categoryDetail":
                
                let destVC = segue.destination as! CategoryDetailViewController
                
                if let name = self.category?.name
                {
                    destVC.categoryName = name
                }
                
                if let notes = self.category?.notes
                {
                    destVC.categoryNotes = notes
                }
                
                if let budget = self.category?.monthlyBudget
                {
                    destVC.categoryBudget = budget
                }
                
            
                if self.category != nil
                {
                    destVC.category = self.category
                }
                
            case "addExpense":
                if let category = self.category
                {
                    let destVC = segue.destination as! AddExpenseViewController
                    destVC.category = category
                    
                    
                }
            default:
                break
            }
        }
    }
}

