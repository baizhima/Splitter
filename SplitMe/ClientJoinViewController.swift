//
//  ClientJoinViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ClientJoinViewController: UIViewController, UITextFieldDelegate {

    var timer: NSTimer?
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var inputCodeField: UITextField!
    @IBOutlet weak var connectInfo: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("clientJoinToHome", sender: self)
    }
    
    // return true if successfully joint the dinner session
    func joinMeal(slave: User, code: String) -> Bool{
        
        let query = PFQuery(className: Meal.parseClassName())
        query.whereKey("code", equalTo: code)
        query.findObjectsInBackgroundWithBlock {
            (objects, error ) -> Void in
            if error == nil{
                if let meal = objects?.first as? Meal{
                   
                    Meal.currentMeal = meal
                    
                    if meal.state >= Meal.AllUserJoined{
                        self.connectInfo.text = "group closed, sorry"
                        return
                    }
                    
                    slave.state = User.UserJoined
                    slave.saveInBackground()
                    
                    //meal.users.append(slave)
                    meal.addUniqueObject(slave, forKey: "users")
                    
                    meal.saveInBackgroundWithBlock({
                        (success, error ) -> Void in
                        if(success){
                            self.confirmButton.setTitle("Succeed! Waiting others..", forState: UIControlState.Normal)
                            self.backButton.enabled = false
                            //self.connectInfo.text = "joined successfully! Waiting others.."
                            //self.inputCodeField.enabled = false
                            //self.confirmButton.enabled = false
                            //
                        }
                    })
                    self.confirmButton.backgroundColor = UIColor(red: 195.0/255, green: 195.0/255, blue: 195.0/255, alpha: 1.0)
                    self.inputCodeField.enabled = false
                    self.confirmButton.enabled = false
                }else{
                    self.connectInfo.text = "Invalid group code. Try again."
                    self.connectInfo.hidden = false
                    self.confirmButton.setTitle("confirm", forState: UIControlState.Normal)
                    //self.connectInfo.text = "Invalid group code. Try again."
                }
            }else{
                print("query meal error: \(error)")
            }
        }
        return false;
    }
    
    @IBAction func confirmPressed(sender: UIButton) {
        
        //inputCodeField.resignFirstResponder()
        
        if inputCodeField.text == "" {
            connectInfo.text = "Please input the code..."
            connectInfo.hidden = false
            return
        }
        let code = Int(inputCodeField!.text!)!
        if code > 9999 || code < 1000 {
            connectInfo.text = "Code is 4 digits"
            connectInfo.hidden = false
            return
        }
        
        //connectInfo.text = "Connecting \(code)..."
        confirmButton.setTitle("Connecting \(code)...", forState: UIControlState.Normal)
        
        connectInfo.hidden = true
        joinMeal(User.currentUser!, code: String(code))

    }
    
    func fetchMeal(){
        
        if let meal: Meal = Meal.currentMeal {
       
            meal.fetchInBackgroundWithBlock {
                (object, error) -> Void in
                if error != nil{
                   print(error )
                }
            }
            
            if meal.state >= Meal.AllUserJoined {
                if let timer = self.timer {
                   timer.invalidate() 
                }
                
                performSegueWithIdentifier("clientJoinToTypeOwnDishes", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectInfo.hidden = true
        
        /*
        let bgColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1)
        
        
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20 + 44)
        )
        
        statusBarView.backgroundColor = bgColor
        self.view.addSubview(statusBarView)*/
        
        confirmButton.layer.shadowColor = UIColor.blackColor().CGColor
        confirmButton.layer.shadowOffset = CGSizeMake(3, 3)
        confirmButton.layer.shadowOpacity = 0.8
        confirmButton.layer.shadowRadius = 0.0
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        inputCodeField.resignFirstResponder()
        
        return true
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
