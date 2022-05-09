//
//  AddTransactionViewController.swift
//  ExpenseTracker
//
//  Created by Rishabh Goyal on 08/04/22.
//

import UIKit
import CoreData

protocol TxnDetailsProtocol{
    func getTxnDetails(obj : DataClass)
}

class AddTransactionViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var myUiPicker: UIPickerView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    let pickerList = [ "Income" , "Expense" ]
    var selectedPickerValue : String = ""
    
    var delegate : TxnDetailsProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: TextField Delegates
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        amountTextField.delegate = self
        // -----------------------------------
        
        //MARK: picker view delegate and data soucre marked in storyboard
        
        //  -----------------------------------
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // default selection of "Income" in UI-Picker
        self.myUiPicker.selectRow(0, inComponent: 0, animated: true)
        selectedPickerValue = pickerList[0]
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let dataObj = DataClass()
        fillDataObject(obj: dataObj)
        
        delegate?.getTxnDetails(obj: dataObj)
        
        clearForm()
        
        navigationController?.popViewController(animated: true)
        
//      navigationController?.popToRootViewController(animated: true)
//      Pops all the view controllers on the stack except the root view controller and updates the display.
        
//      self.dismiss(animated: true)// if not using navigation controller
    }
    
    func fillDataObject(obj:DataClass){
        
        if( amountTextField.text == "" ){
            obj.amount = 0
        }else{
            let amt : Int = Int(amountTextField.text!)!
            obj.amount = amt
        }
        print( "picker   :   " , selectedPickerValue )
        
        
        obj.totalIncome = retrieveBalanceData()[0]
        obj.totalExpense = retrieveBalanceData()[1]
        
        if selectedPickerValue == "Income" { // income
            obj.isIncome = true
            obj.totalIncome = obj.totalIncome + obj.amount!
        }else{ // expense
            obj.isIncome = false
            obj.totalExpense = obj.totalExpense + obj.amount!
        }
        
        
        
        obj.title = titleTextField.text == "" ? nil : titleTextField.text
        obj.description = descriptionTextField.text == "" ? nil : descriptionTextField.text
        
    }
    
    func clearForm(){
        self.titleTextField.text = ""
        self.descriptionTextField.text = ""
        self.amountTextField.text = ""
        self.selectedPickerValue = "Income" // default
    }
    
    func retrieveBalanceData( ) -> [Int] {
        // As we know that container is set up in the App Delegates , so we need to refer that container
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [0,0] }
        
        // we need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Prepare the request of type NSFetchRequest for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            
            if result.count > 0 {
                
                if let resultArray = result as? [Transaction]{
                    // typecase result to "Transaction" Array as our entity name is Transaction
                    let totalincome = Int( resultArray[resultArray.count-1].totalIncomeAttribute )
                    let totalexpense = Int( resultArray[resultArray.count-1].totalExpenseAttribute )
                    print( "total income : " , totalincome , "  total expense : " , totalexpense )
                    return [totalincome,totalexpense]
                }
                
            }else{
                return [0,0]
            }
            
        }
        catch{
            print("FAILED")
        }
        return [0,0]
    }
    
}

extension AddTransactionViewController : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerValue = pickerList[row]
    }
}
extension AddTransactionViewController : UIPickerViewDelegate {
    
}
