import UIKit
import CoreData
import EventKit

class AddExpenseViewController: UIViewController {

    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var textFieldExpenseAmount: UITextField!
    @IBOutlet weak var DatePickerExpense: UIDatePicker!
    
    @IBOutlet weak var SegmentOccurrence: UISegmentedControl!
    @IBOutlet weak var SwitchAddToCalendar: UISwitch!
    @IBOutlet weak var textFieldNotes: UITextField!
    
    var category:Category?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.labelCategoryName.text = self.category?.name
        
        
    }
    
    @IBAction func saveExpense(_ sender: UIButton) {
        if self.category != nil
        {
            if (self.textFieldExpenseAmount.text != "" && self.textFieldNotes.text != "")
            {
                let str = self.textFieldExpenseAmount.text!
                if let num = Double(str)
                {
                    
                    let expense = Expense(context: context)
                    
                    expense.amount = NSDecimalNumber(string: textFieldExpenseAmount.text)
                    expense.reminderFlag = SwitchAddToCalendar.isOn
                    expense.date = DatePickerExpense.date
                    
                    //Checking occurrence of the expense with a switch case
                    switch SegmentOccurrence.selectedSegmentIndex {
                    case 0:
                        expense.occurrence = "OneOff"
                        break
                    case 1:
                        expense.occurrence = "Daily"
                        break
                    case 2:
                        expense.occurrence = "Weekly"
                        break
                    case 3:
                        expense.occurrence = "Monthly"
                        break
                    default:
                        break
                    }
                    
                    expense.notes = textFieldNotes.text
                    
                    if(expense.reminderFlag)
                    {
                        let eventStore : EKEventStore = EKEventStore()
                        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
                        eventStore.requestAccess(to: .event) { (granted, error) in
                          
                          if (granted) && (error == nil) {
                              print("granted \(granted)")
                              print("error \(error)")
                              
                              let event:EKEvent = EKEvent(eventStore: eventStore)
                              
                            event.title = "Expense Reminder of £\(expense.amount!)"
                              event.startDate = expense.date
                              event.endDate = expense.date
                              event.notes = expense.notes
                              event.calendar = eventStore.defaultCalendarForNewEvents
                              do {
                                  try eventStore.save(event, span: .thisEvent)
                              } catch let error as NSError {
                                  print("failed to save event with error : \(error)")
                              }
                              print("Saved Event")
                          }
                          else{
                          
                              print("failed to save event with error : \(error) or access not granted")
                          }
                        }
                    }
                    
                    //Save the expense to a specific category
                    category?.addToExpenses(expense)
                    
                    //duplicate bug here is not the problem
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    navigationController?.popViewController(animated: true)

                    dismiss(animated: true, completion: nil)
                    
                    return
                }
            }
        }
        
        let alert = UIAlertController(title: "Invalid Input", message: "Invalid input detected, please try again.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

        self.present(alert, animated: true)
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
