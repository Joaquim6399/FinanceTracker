
import UIKit

class AddCategoryViewController: UIViewController, UIColorPickerViewControllerDelegate {

    @IBOutlet weak var textFieldCategoryName: UITextField!
    @IBOutlet weak var textFieldBudget: UITextField!
    @IBOutlet weak var textFieldNotes: UITextField!
    @IBOutlet weak var categorySaveBtn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var pickedColorPanel: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categorySaveBtn.layer.borderWidth = 1
        categorySaveBtn.layer.cornerRadius = 12
        categorySaveBtn.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func colorBtnPressed(_ sender: UIButton) {
        
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
    }
    
    @IBAction func saveCategoryBtn(_ sender: UIButton) {
        //new managed object
        
        //User input validation
        if (self.textFieldCategoryName.text != "" && self.textFieldBudget.text != "")
        {

            //Make sure it is a number
            let str = self.textFieldBudget.text!
            if let num = Double(str)
            {
                let newCategory = Category(context: context)

                print(num)
                
                newCategory.name = self.textFieldCategoryName.text
                newCategory.notes = self.textFieldNotes.text
                newCategory.monthlyBudget = NSDecimalNumber(string: self.textFieldBudget.text)
                newCategory.colour = colorPicked
                
                //Save
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                //self.presentation.wrappedValue.dismiss()
                navigationController?.popViewController(animated: true)

                dismiss(animated: true, completion: nil)
                
                return
            }
            
        }
        
        //Alert of invalid input
       // let alert = UIAlertController(title: "", message: "Invalid Input, try again", preferredStyle: .alert)

        let alert = UIAlertController(title: "Invalid Input", message: "Invalid input detected, please try again.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    
    @IBOutlet var colorBtns: [UIButton]!
    
    
    var colorPicked:UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
    
    @IBAction func changeColor(_ sender: UIButton)
    {
        
        
        colorPicked = sender.backgroundColor!
        
        pickedColorPanel.backgroundColor = sender.backgroundColor!
        
    }
    
    
    

}
