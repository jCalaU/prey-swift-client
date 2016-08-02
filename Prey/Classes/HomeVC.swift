//
//  HomeVC.swift
//  Prey
//
//  Created by Javier Cala Uribe on 27/11/14.
//  Copyright (c) 2014 Fork Ltd. All rights reserved.
//

import UIKit

class HomeVC: GAITrackedViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    
    // MARK: Properties
    
    @IBOutlet weak var titleLbl             : UILabel!
    @IBOutlet weak var subtitleLbl          : UILabel!
    @IBOutlet weak var shieldImg            : UIImageView!
    @IBOutlet weak var camouflageImg        : UIImageView!
    @IBOutlet weak var passwordInput        : UITextField!
    @IBOutlet weak var loginBtn             : UIButton!
    @IBOutlet weak var forgotBtn            : UIButton!
    
    @IBOutlet weak var accountImg           : UIImageView!
    @IBOutlet weak var accountSbtLbl        : UILabel!
    @IBOutlet weak var accountTlLbl         : UILabel!
    @IBOutlet weak var accountBtn           : UIButton!
    @IBOutlet weak var settingsImg          : UIImageView!
    @IBOutlet weak var settingsSbtLbl       : UILabel!
    @IBOutlet weak var settingsTlLbl        : UILabel!
    @IBOutlet weak var settingsBtn          : UIButton!
    
    @IBOutlet weak var tourImg              : UIImageView!
    @IBOutlet weak var tourBtn              : UIButton!
    
    var hidePasswordInput = false
    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // View title for GAnalytics
        self.screenName = "Login"        
        
        // Dismiss Keyboard on tap outside
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.dismissKeyboard(_:)))
        view.addGestureRecognizer(recognizer)
        
        // Config init
        hidePasswordInputOption(hidePasswordInput)
        
        // Config Prey Tour
        configPreyTour()
        
        // Config texts
        configureTexts()
        
        // Check device auth
        checkDeviceAuth()
        
        // Check for Rate us
        PreyRateUs.sharedInstance.askForReview()
        
        // Check new version on App Store
        PreyConfig.sharedInstance.checkLastVersionOnStore()
        
        // Hide camouflage image
        configCamouflageMode(PreyConfig.sharedInstance.isCamouflageMode)
    }

    func configureTexts() {

        loginBtn.setTitle("Log In".localized, forState:.Normal)
        forgotBtn.setTitle("Forgot your password?".localized, forState:.Normal)
        
        passwordInput.placeholder   = "Type in your password".localized
        subtitleLbl.text            = "current device status".localized
        accountTlLbl.text           = "PREY ACCOUNT".localized
        accountSbtLbl.text          = "REMOTE CONTROL FROM YOUR".localized
        settingsTlLbl.text          = "PREY SETTINGS".localized
        settingsSbtLbl.text         = "CONFIGURE".localized
    }
    
    // Check device auth
    func checkDeviceAuth() {
        let isAllAuthAvailable  = DeviceAuth.sharedInstance.checkAllDeviceAuthorization()
        titleLbl.text    = isAllAuthAvailable ? "PROTECTED".localized.uppercaseString : "NOT PROTECTED".localized.uppercaseString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
        // Hide navigationBar when appear this ViewController
        self.navigationController?.navigationBarHidden = true
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(HomeVC.handleKeyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(HomeVC.handleKeyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        // Hide navigationBar when appear this ViewController
        self.navigationController?.navigationBarHidden = false
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Hide password input
    func hidePasswordInputOption(value:Bool) {

        UIView.animateWithDuration(10.0, animations: {
            // Input subview
            self.passwordInput.hidden   = value
            self.loginBtn.hidden        = value
            self.forgotBtn.hidden       = value
            
            // Menu subview
            self.accountImg.hidden      = !value
            self.accountSbtLbl.hidden   = !value
            self.accountTlLbl.hidden    = !value
            self.accountBtn.hidden      = !value
            self.settingsImg.hidden     = !value
            self.settingsSbtLbl.hidden  = !value
            self.settingsTlLbl.hidden   = !value
            self.settingsBtn.hidden     = !value
            self.tourImg.hidden         = !value
            self.tourBtn.hidden         = !value
        })
    }
    
    func configCamouflageMode(isCamouflage:Bool) {

        subtitleLbl.hidden      = isCamouflage
        titleLbl.hidden         = isCamouflage
        shieldImg.hidden        = isCamouflage
        
        camouflageImg.hidden    = !isCamouflage
    }
    
    // Config Prey Tour
    func configPreyTour() {
        
        if PreyConfig.sharedInstance.hideTourWeb {
            closePreyTour()
            return
        }
        
        // Add tap gesture to View
        let tap         = UITapGestureRecognizer(target:self, action:#selector(startPreyTour))
        tap.delegate    = self
        
        // Add tap to tourImg
        tourImg.userInteractionEnabled = true
        tourImg.addGestureRecognizer(tap)
        
        // Add target to tourBtn
        tourBtn.addTarget(self, action:#selector(closePreyTour), forControlEvents:.TouchUpInside)
        
        // Check language in tourImg
        if let language:String = NSLocale.preferredLanguages()[0] as String {
            let languageES = (language as NSString).substringToIndex(2)
            if languageES == "es" {
                tourImg.image = UIImage(named:"TourEs")
            }
        }
    }
    
    // Start Prey Tour
    func startPreyTour() {
        
        guard let language:String = NSLocale.preferredLanguages()[0] as String else {
            PreyLogger("Error get preferredLanguage")
            return
        }
        
        let languageES  = (language as NSString).substringToIndex(2)
        
        let indexPage   = (languageES == "es") ? "index-es" : "index"
        let url         = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(indexPage, ofType:"html", inDirectory:"PreyTourWeb")!)
        
        let controller  = WebVC(withURL:url, withParameters:nil, withTitle:"Prey Tour")
        self.presentViewController(controller, animated:true, completion:nil)
    }
    
    // Close Prey Tour
    func closePreyTour() {
        tourImg.removeFromSuperview()
        tourBtn.removeFromSuperview()
    }
    
    // MARK: Keyboard Event Notifications
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
    }
    
    func dismissKeyboard(tapGesture: UITapGestureRecognizer) {
        // Dismiss keyboard if is inside from UIView
        if (CGRectContainsPoint(self.view.frame, tapGesture.locationInView(self.view))) {
            self.view.endEditing(true);
        }
    }
    
    func keyboardWillChangeFrameWithNotification(notification: NSNotification, showsKeyboard: Bool) {
        let userInfo = notification.userInfo!
        
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        self.view.center.y += originDelta
        
        view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: .BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTage = textField.tag + 1;

        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder == nil) {
            checkPassword(nil)
        }
        return false
    }
    
    // MARK: Functions
    
    // Send GAnalytics event
    func sendEventGAnalytics() {
        if let tracker = GAI.sharedInstance().defaultTracker {
            
            let dimensionValue = PreyConfig.sharedInstance.isPro ? "Pro" : "Free"
            tracker.set(GAIFields.customDimensionForIndex(1), value:dimensionValue)
            
            let params = GAIDictionaryBuilder.createEventWithCategory("UserActivity", action:"Log In", label:"Log In", value:nil).build() as [NSObject:AnyObject]
            tracker.send(params)
        }
    }

    // Go to Settings
    @IBAction func goToSettings(sender: UIButton) {
        
        if let resultController = self.storyboard!.instantiateViewControllerWithIdentifier(StoryboardIdVC.settings.rawValue) as? SettingsVC {
            self.navigationController?.pushViewController(resultController, animated: true)
        }
    }
    
    // Go to Control Panel
    @IBAction func goToControlPanel(sender: UIButton) {

        if let token = PreyConfig.sharedInstance.tokenPanel {
            let params           = String(format:"token=%@", token)
            let controller       = WebVC(withURL:NSURL(string:URLSessionPanel)!, withParameters:params, withTitle:"Control Panel Web")
            self.presentViewController(controller, animated:true, completion:nil)
            
        } else {
            displayErrorAlert("Error, retry later.".localized,
                              titleMessage:"We have a situation!".localized)
        }
    }
    
    // Run web forgot
    @IBAction func runWebForgot(sender: UIButton) {
     
        let controller       = WebVC(withURL:NSURL(string:URLForgotPanel)!, withParameters:nil, withTitle:"Forgot Password Web")
        self.presentViewController(controller, animated:true, completion:nil)
    }
    
    // Check password
    @IBAction func checkPassword(sender: UIButton?) {
        
        // Check password length
        if passwordInput.text!.characters.count < 6 {
            displayErrorAlert("Password must be at least 6 characters".localized,
                              titleMessage:"We have a situation!".localized)
            return
        }
        
        // Hide keyboard
        self.view.endEditing(true)
        
        // Show ActivityIndicator
        let actInd          = UIActivityIndicatorView(initInView: self.view, withText:"Please wait".localized)
        self.view.addSubview(actInd)
        actInd.startAnimating()

        
        // Get Token for Control Panel
        PreyUser.getTokenFromPanel(PreyConfig.sharedInstance.userApiKey!, userPassword:self.passwordInput.text!, onCompletion:{(isSuccess: Bool) in

            // Hide ActivityIndicator
            dispatch_async(dispatch_get_main_queue()) {
                actInd.stopAnimating()
             
                // Change inputView
                if isSuccess {
                    self.sendEventGAnalytics()
                    self.hidePasswordInputOption(true)
                }
            }
        })
    }
}
