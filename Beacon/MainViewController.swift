//
//  MainViewController.swift
//  Beacon
//
//  Created by Juliet Liu on 2015-07-14.
//  Copyright (c) 2015 Juliet Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var myCore : SparkDevice?
    var deviceOK = false
    var timer = NSTimer()
    var inAutoOffMode = 0
    var deviceMode = 0
    
    // init the buttons
    
    func updateUI() {
        println("updating UI...")
        if self.inAutoOffMode == 1 {
            self.shutDownButton.enabled = true
            self.delayButton.enabled = true
        }
        else {
            self.shutDownButton.enabled = false
            self.delayButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.shutDownButton.enabled = false
        self.delayButton.enabled = false
        
        SparkCloud.sharedInstance().loginWithUser("julietliu94@gmail.com", password: "atefjuliet") { (error:NSError!) -> Void in
            if let e=error {
                println("wrong credentials")
            }
            else {
                println("logged in!")
                
                println("log in should've finished")
                SparkCloud.sharedInstance().getDevices { (sparkDevices:[AnyObject]!, error:NSError!) -> Void in
                    if let e = error {
                        println("Check your internet connectivity")
                    }
                    else {
                        if let devices = sparkDevices as? [SparkDevice] {
                            //println(sparkDevices)
                            for device in devices {
                                if device.name == "enzo" {
                                    println("Enzo is here")
                                    self.myCore = device
                                    self.deviceOK = true
                                    
                                    self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector: Selector("callFetch"), userInfo: nil, repeats: true)
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callFetch() {
        fetch{}
    }
    
    func fetch(completion: () -> Void) {
        myCore?.getVariable("auto-off", completion: {
            (result:AnyObject!, error:NSError!) -> Void in
            if let e=error {
                println("Failed reading 'auto-off' from device")
            }
            else {
                if let autoOffFlag = result as? Int {
                    println("AutoOff is \(autoOffFlag)")
                    if self.inAutoOffMode != autoOffFlag {
                        self.inAutoOffMode = autoOffFlag
                        self.updateUI()
                    }
                }
            }
        })
        
        myCore?.getVariable("device", completion: {
            (result:AnyObject!, error:NSError!) -> Void in
            if let e=error {
                println("Failed reading 'device' from device")
            }
            else {
                if let deviceState = result as? Int {
                    println("Device is \(deviceState)")
                    if self.deviceMode != deviceState {
                        self.deviceMode = deviceState
                        self.updateUI()
                    }
                }
            }
            
        })
        
        completion()
    }
    
    @IBAction func shutDownButtonTapped(sender: UIButton) {
        println("button tapped")
        self.shutDownButton.enabled = false
        
        if self.deviceOK {
            let funcArgs = ["blah",1]
            self.myCore!.callFunction("turn-off", withArguments: funcArgs) { (resultCode : NSNumber!, error : NSError!) -> Void in
                if (error == nil) {
                    self.shutDownButton.setTitle("Device has shut down", forState: UIControlState.Normal)
                    println("shutting down")
                }
            }
        } else {
            println("login first")
        }
    }
    
    @IBAction func delayButtonTapped(sender: UIButton) {
        println("delay button tapped")
        self.delayButton.enabled = false
        
        if self.deviceOK {
            let funcArgs = ["blah",1]
            self.myCore!.callFunction("set-pause", withArguments: funcArgs) { (resultCode : NSNumber!, error : NSError!) -> Void in
                if (error == nil) {
                    self.delayButton.setTitle("Shutdown delayed", forState: UIControlState.Normal)
                    println("shutdown delayed!")
                }
            }
        } else {
            println("login first")
        }
        
    }
}


