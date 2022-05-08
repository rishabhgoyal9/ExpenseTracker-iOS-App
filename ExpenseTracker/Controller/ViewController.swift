//
//  ViewController.swift
//  ExpenseTracker
//
//  Created by Rishabh Goyal on 08/05/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var totalBalanceView: UIView!
    @IBOutlet weak var totalIncomeView: UIView!
    @IBOutlet weak var totalExpenseView: UIView!
    
    var dataArray : [DataClass] = [DataClass]()
    var btn = UIButton(type: .custom)
    
    var topSafeArea: CGFloat?
    var bottomSafeArea: CGFloat?
    
    var availableHeight: CGFloat?
    var availableWidth: CGFloat?
    
    var totalBalance : Int = 0
    
    lazy var addTransactionVC : AddTransactionViewController = {
        let addTransactionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTransactionViewControllerID") as! AddTransactionViewController
        return addTransactionVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      Delegate and Datasource of tableciew is marked in Storyboard
        myTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "customTableCellIdentifier")
        myTableView.estimatedRowHeight = 150
        myTableView.rowHeight = UITableView.automaticDimension
        myTableView.separatorStyle = .none
        findAvailableHeight()
        
        addTransactionVC.delegate = self // important
        
//      floatingButton() // dont do it here , as viewdidload called only once and if we came back from another screen then this button will diappear so , call it from viewwill appear
        
        //MARK: Initial Money Flow
        
        totalBalanceLabel.text = "₹0"
        totalIncomeLabel.text = "+₹0"
        totalExpenseLabel.text = "-₹0"
        // ------------------------------
        
        //MARK: Core Data
        dataArray = self.retrieveData() ?? [DataClass]()
        // -------------------------------
        
        totalBalanceView.layer.cornerRadius = 20
        totalIncomeView.layer.cornerRadius = 20
        totalExpenseView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        floatingButton()
    }
    
    func findAvailableHeight(){
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            topSafeArea = window!.safeAreaInsets.top
            bottomSafeArea = window!.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
        availableHeight = self.view.bounds.height - topSafeArea! - bottomSafeArea! - 40 // 40 is navigation bar height
        availableWidth = self.view.bounds.width
    }
    
    func floatingButton(){
        btn.frame = CGRect(x: availableWidth! - 50 - 10 , y: availableHeight! + topSafeArea! + 40 - 50 - 10 , width: 50, height: 50)
        /*
         width
                -50 : floating button width
                -10 : give margin
         
         height
                +topSafeArea : bcz availableHeight don't have it
                +40 : height of navigation bar title
                 -50 : floating button height
                 -10 : give margin
         */
        btn.setTitle("+", for: .normal)
        btn.backgroundColor = UIColor.blue
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 25
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1.0
        btn.addTarget(self,action: #selector(buttonTapped(button:)), for: .touchUpInside)
        if #available(iOS 13, *){
            if let window = UIApplication.shared.windows.first { $0.isKeyWindow } {
                window.addSubview(btn)
            }
        }else{
            if let window = UIApplication.shared.keyWindow {
                window.addSubview(btn)
            }
        }
        
    }
    
    @objc func buttonTapped( button: UIButton){
        self.navigationController?.pushViewController(addTransactionVC, animated: true) // Side Opening
//        self.present(addTransactionVC, animated: true) // bottom to top opening
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        btn.removeFromSuperview()
        // Unlinks the view from its superview and its window, and removes it from the responder chain.
    }
    
    func updateUIBalance(){
        //MARK: Set overall Money Flow
        totalIncomeLabel.text = "+₹\(dataArray[0].totalIncome)"
        totalExpenseLabel.text = "-₹\(dataArray[0].totalExpense)"
        // because coredata array filled left to right
        // but data array is filled reverse while retrieving data from coredata
        // so item at last in core data , comes at first in dat array
        if dataArray[0].totalIncome == dataArray[0].totalExpense{
            totalBalanceLabel.text = "+₹0"
            totalBalanceView.backgroundColor = UIColor.white
        }
        else if dataArray[0].totalIncome > dataArray[0].totalExpense{ // Profit
            totalBalance = dataArray[0].totalIncome - dataArray[0].totalExpense
            totalBalanceLabel.text = "+₹\(totalBalance)"
            
            totalBalanceView.backgroundColor = UIColor(red: 120/255, green: 188/255, blue: 140/255, alpha: 1)
            
        }else{ // Loss
            totalBalance = dataArray[0].totalExpense - dataArray[0].totalIncome
            totalBalanceLabel.text = "-₹\(totalBalance)"
            
            totalBalanceView.backgroundColor = UIColor(red: 235/255, green: 133/255, blue: 126/255, alpha: 1)
        }
    }
    
}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "customTableCellIdentifier", for: indexPath) as! CustomTableViewCell
        cell.configureUI(obj: dataArray[indexPath.row])
        updateUIBalance()
        return cell
    }
    
}

extension ViewController : UITableViewDelegate{
    
}

extension ViewController : TxnDetailsProtocol {
    
    func getTxnDetails(obj: DataClass) {
        fillCoreData(obj: obj)
        myTableView.reloadData()
    }
    
    func fillCoreData( obj : DataClass ){
        saveObjData(obj: obj) // enter our entry into DB
        dataArray = self.retrieveData() ?? [DataClass]() //update that entry into our dataArray
    }
    
}

extension ViewController{
    
    //MARK: Core Data Functions
    
    func saveObjData( obj : DataClass ){
        
        // As we know that container is set up in the App Delegates , so we need to refer that container
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // we need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Now , lets create an entity and new MoneyFlow records.
        let transactionEntitiy = NSEntityDescription.entity(forEntityName: "Transaction", in: managedContext)!
      
        let txn = NSManagedObject(entity: transactionEntitiy, insertInto: managedContext)

        txn.setValue(obj.amount, forKey: "amountAttribute")
        txn.setValue(obj.isIncome, forKey: "isIncomeAttribute")
        txn.setValue(obj.title, forKey: "titleAttribute")
        txn.setValue(obj.description, forKey: "descriptionAttribute")
        txn.setValue(obj.totalIncome, forKey: "totalIncomeAttribute")
        txn.setValue(obj.totalExpense, forKey: "totalExpenseAttribute")

        // Now we have set all the values. Next step is to save them inside the Core Data
        do{
            try managedContext.save()
        }catch{
            print( "could not save  \(error) " )
        }
        
    }

    func retrieveData( ) -> [DataClass]? {
        // As we know that container is set up in the App Delegates , so we need to refer that container
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        // we need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Prepare the request of type NSFetchRequest for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            
            if result.count > 0 {
                
                if let resultArray = result as? [Transaction]{
                    // typecase result to "Transaction" Array as our entity name is Transaction
                    
                    var dataClassList = [DataClass]()
                    
                    for obj in resultArray.reversed() { // reversed so that new data added at top
                        
                        let dataClassObj = DataClass()
                        
                        dataClassObj.isIncome = obj.isIncomeAttribute
                        dataClassObj.amount = Int(obj.amountAttribute)
                        dataClassObj.description = obj.descriptionAttribute ?? ""
                        dataClassObj.title = obj.titleAttribute ?? ""
                        dataClassObj.totalIncome = Int(obj.totalIncomeAttribute) // bcz totalIncomeAttribute is of type Int64 and dataclass has member totalIncome of type Int
                        dataClassObj.totalExpense = Int(obj.totalExpenseAttribute)
                        
                        dataClassList.append( dataClassObj )
                    }
                    
                    return dataClassList
                    
                }
                
            }else{
                return nil
            }
            
        }
        catch{
            print("FAILED")
        }
        return nil
    }
    
}
