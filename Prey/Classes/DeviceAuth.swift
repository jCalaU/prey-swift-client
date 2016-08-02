//
//  DeviceAuth.swift
//  Prey
//
//  Created by Javier Cala Uribe on 26/05/16.
//  Copyright © 2016 Fork Ltd. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

class DeviceAuth: NSObject, UIAlertViewDelegate {

    // MARK: Singleton
    
    static let sharedInstance = DeviceAuth()
    private override init() {
    }

    // MARK: Methods
    
    // Check all device auth
    func checkAllDeviceAuthorization() -> Bool{
        if checkNotify() && checkLocation() && checkCamera() {
            return true
        }
        return false
    }
    
    // Check notification
    func checkNotify() -> Bool {
        
        var notifyAuth = false
        
        if #available(iOS 8.0, *) {
            let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
            notifyAuth = notificationSettings?.types.rawValue > 0
        } else {
            notifyAuth = true
        }
 
        if !notifyAuth {
            displayMessage("You need to grant Prey access to show alert notifications in order to remotely mark it as missing.".localized,
                           titleMessage:"Alert notification disabled".localized)
        }
        
        return notifyAuth
    }
    
    // Check location
    func checkLocation() -> Bool {
        
        var locationAuth = false
        
        if (CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() != .NotDetermined &&
            CLLocationManager.authorizationStatus() != .Denied &&
            CLLocationManager.authorizationStatus() != .Restricted) {
            locationAuth = true
        }
        
        if !locationAuth {
            displayMessage("Location services are disabled for Prey. Reports will not be sent.".localized,
                           titleMessage:"Enable Location".localized)
        }
        
        return locationAuth
    }
    
    // Check camera
    func checkCamera() -> Bool {
        
        var cameraAuth = false
        
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized {
            cameraAuth = true
        } else {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler:{(granted: Bool) in
                cameraAuth = granted
            })
        }
        
        if !cameraAuth {
            displayMessage("Camera is disabled for Prey. Reports will not be sent.".localized,
                           titleMessage:"Enable Camera".localized)
        }
        
        return cameraAuth
    }
    
    // Display message
    func displayMessage(alertMessage:String, titleMessage:String) {
        
        let acceptBtn = IS_OS_8_OR_LATER ? "Go to Settings".localized : "OK".localized
        let cancelBtn = IS_OS_8_OR_LATER ? "Cancel".localized : ""
        
        let anAlert   = UIAlertView(title:titleMessage,
                                    message:alertMessage,
                                    delegate:self,
                                    cancelButtonTitle:acceptBtn,
                                    otherButtonTitles:cancelBtn)
        anAlert.show()
    }

    // MARK: UIAlertViewDelegate
    
    // AlertView
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        guard buttonIndex == 0 else {
            return
        }
        
        if #available(iOS 8.0, *) {
            let url = NSURL(string:UIApplicationOpenSettingsURLString)!
            UIApplication.sharedApplication().openURL(url)
        }
    }
}