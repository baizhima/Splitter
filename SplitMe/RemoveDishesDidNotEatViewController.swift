//
//  RemoveDishesDidNotEatViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class RemoveDishesDidNotEatViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var promptField: UILabel!
    var sharedDishes : [Dish]?
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverCheckSubtotalToRemoveDishesDidNotEat", sender: self)
    }
    
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        
        if let meal = Meal.currentMeal {
            if let user = User.currentUser {
                if meal.master.objectId == user.objectId {
                    self.performSegueWithIdentifier("removeDishesDidNotEatToServerConfirmTotal", sender: self)
                }
                else {
                    promptField.hidden = false
                }
            }
        }
        
        
    }
    
    func fetchSharedDishes() -> [Dish]?{
        
        if let meal = Meal.currentMeal {
            
            let query = Dish.query()
            query?.whereKey("meal", equalTo: meal)
            query?.whereKey("isShared", equalTo: true)
            do{
                try sharedDishes = query?.findObjects() as? [Dish]
                return sharedDishes
            }catch _{
                debugPrint("Error in fetching dishes")
            }
        }else{
            debugPrint("Error: current meal is nil")
        }
        return nil
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promptField.hidden = true
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sharedDishes == nil{
            self.sharedDishes = fetchSharedDishes()
        }
        
        if let dishes = self.sharedDishes{
            return dishes.count
        }
        else{
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        if self.sharedDishes == nil{
            self.sharedDishes = fetchSharedDishes()
        }
        
        if let dishes = self.sharedDishes {
            let dish: Dish = dishes[indexPath.row]
            
            newCell.textLabel!.text = "\(dish.name)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", dish.price))
        }else{
            debugPrint("Error: tableView: dishes is empty")
        }
        
        
        return newCell
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
