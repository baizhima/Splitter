//
//  ClientDetailViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/30.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ClientDetailViewController: UIViewController, UITableViewDelegate {
    
    var dishes: [Dish] = [Dish]()
    var tips : Double = 0.0
    var tax : Double = 0.0
    var totalPayment : Double = 0.0
    var meal : Meal?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    func getMyPayment(dish: Dish) -> Double{
        var myprice : Double = dish.price
        if( dish.isShared && dish.sharedWith.count > 0){
            myprice = dish.price / Double(dish.sharedWith.count)
        }
        return myprice
    }
    
    func setTotalLabel(){
        
        totalLabel.text = "$ " + String(NSString(format:"%.2f", (User.currentUser?.payment)!))
        
    }
    
    func setTipsAndTax(){
        
        let myTax = ((User.currentUser?.payment)! / (meal?.total)!) * (meal?.tax)!
        let myTips = ((User.currentUser?.payment)! / (meal?.total)!) * (meal?.tips)!
        
        self.taxLabel.text = "$" + String(NSString(format:"%.2f", myTax))
        self.tipsLabel.text = "$" + String(NSString(format:"%.2f", myTips))

    }
    
    func fetchMeal(){
        Meal.currentMeal?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            
            self.meal = object as? Meal
            self.setTipsAndTax()
            //self.tableView.reloadData()
        })
    }
    
    func fetchDishes(){
        
        if let meal = Meal.currentMeal {
            
            let query = Dish.query()
            query?.whereKey("meal", equalTo: meal)

            //query?.whereKey("shared", containedIn: <#T##[AnyObject]#>)
            query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil{
                    
                    for d : Dish in objects as! [Dish] {
                        if d.isShared == true {
                            for u : User in d.sharedWith {
                                if u.objectId == User.currentUser?.objectId{
                                    self.dishes.append(d)
                                    break
                                }
                            }
                        }
                        else if d.ownBy.objectId == User.currentUser?.objectId {
                            self.dishes.append(d)
                        }
                    }
                
                    self.tableView.reloadData()
                    
                }
            })
        }
        else{
            debugPrint("Error: current meal is nil")
        }
    }

    @IBAction func backPressed(sender: UIBarButtonItem) {
        
        if User.currentUser?.objectId == Meal.currentMeal!.master.objectId {
            performSegueWithIdentifier("clientDetailToServerToll", sender: self)
        } else {
            performSegueWithIdentifier("clientDetailToClientPay", sender: self)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
/*
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        self.view.addSubview(statusBarView)*/
    }
    
    override func viewDidAppear(animated: Bool) {
        setTotalLabel()
        fetchMeal()
        fetchDishes()
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print("Client Detail: dish count: \(self.dishes.count)")
        return self.dishes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        let dish: Dish = dishes[indexPath.row]
        
        let myprice = getMyPayment(dish)
        
        cell.textLabel!.text = "\(dish.name)"
        cell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", myprice))
        cell.backgroundColor = UIColor(red: 77.0/255, green: 77.0/255, blue: 77.0/255, alpha: 1.0)
        //let idx = indexPath.row
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        
        return cell
        

    }

}
