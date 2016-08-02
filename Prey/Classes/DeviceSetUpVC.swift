//
//  DeviceSetUpVC.swift
//  Prey
//
//  Created by Javier Cala Uribe on 21/11/14.
//  Copyright (c) 2014 Fork Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class DeviceSetUpVC: GAITrackedViewController {

    
    // MARK: Properties

    @IBOutlet weak var titleLbl    : UILabel!
    @IBOutlet weak var messageLbl  : UILabel!
    
    var messageTxt = ""

    // Location Service Auth
    let authLocation = CLLocationManager()

    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View title for GAnalytics
        self.screenName = "Congratulations"
        
        configureTextButton()
        requestDeviceAuth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool){
        // Hide navigationBar when appear this ViewController
        self.navigationController?.navigationBarHidden = true
        
        super.viewWillAppear(animated)
    }
    
    func configureTextButton() {
        titleLbl.text   = "Device set up!".localized.uppercaseString
        messageLbl.text =  messageTxt
    }
    
    // MARK: Functions
    
    func requestDeviceAuth() {

        // Register device to Apple Push Notification Service
        PreyNotification.sharedInstance.registerForRemoteNotifications()

        // Location Service Auth
        if #available(iOS 8.0, *) {
            authLocation.requestAlwaysAuthorization()
        } else {
            authLocation.startUpdatingLocation()
            authLocation.stopUpdatingLocation()
        }
        
        // Camera Auth
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
    }
    
    // Ok pressed
    @IBAction func showHomeView(sender: UIButton) {
        
        // Get SharedApplication delegate
        guard let appWindow = UIApplication.sharedApplication().delegate?.window else {
            PreyLogger("error with sharedApplication")
            return
        }
        
        if let resultController = self.storyboard!.instantiateViewControllerWithIdentifier(StoryboardIdVC.home.rawValue) as? HomeVC {

            resultController.hidePasswordInput = true
            
            // Set controller to rootViewController
            let navigationController:UINavigationController = appWindow!.rootViewController as! UINavigationController
            
            let transition:CATransition = CATransition()
            transition.type             = kCATransitionFade
            navigationController.view.layer.addAnimation(transition, forKey: "")
            navigationController.setViewControllers([resultController], animated: false)
        }
    }
}