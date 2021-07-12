//
//  PaymentsModule.swift
//  Payment
//
//  Created by DEV27 on 21/10/19.
//  Copyright © 2020 myApps. All rights reserved.
//

import UIKit
import Common

public class PaymentsModule {
    public static func getPaymentGatewayVC(withPaymentInitiator initiator:PaymentInitiatorModel, delegate:PaymentGatewayDelegate, successTitle : String? = nil ,successMessage msg:String? = nil, amount:Double, token:String? = nil, fromModule:SuccessModule, isOrderLabel: Bool = false) -> UIViewController!{
        let vc = UIStoryboard.init(name: "Payment", bundle: Bundle.init(for: PaymentsModule.self)).instantiateViewController(withIdentifier: "PaymentGatewayVC") as! PaymentGatewayVC
        vc.initiator = initiator
        vc.delegate = delegate
        vc.successTitle = successTitle
        vc.successMessage = msg
        vc.amount = amount
        vc.token = token
        vc.fromModule = fromModule
        vc.isOrderLabel = isOrderLabel
        
        if payProceedings1() == false, payProceedings2() == false, let _ = paySetupApp(), let _ = payInitialize(){
            return vc
        }else{
            assert(false, "Oops.!!")
            return nil
        }
    }
    
    //Caller needs to handle all cases related to success.
    public static func getPaymentGatewayVC(withPaymentInitiator initiator:PaymentInitiatorModel, delegate:PaymentGatewayDelegate, successDelegate:PaymentSuccessDelegate, amount:Double, caller: String) -> UIViewController!{
            let vc = UIStoryboard.init(name: "Payment", bundle: Bundle.init(for: PaymentsModule.self)).instantiateViewController(withIdentifier: "PaymentGatewayVC") as! PaymentGatewayVC
            vc.initiator = initiator
            vc.delegate = delegate
            vc.successDelegate = successDelegate

            if  payProceedings1() == false, payProceedings2() == false, let _ = paySetupApp(), let _ = payInitialize(){
                return vc
            }else{
                assert(false, "Oops.!!")
            }
            return nil
        }
    
    static func getImage(Named image:PaymentImages) -> UIImage?{
        return UIImage.init(named: image.rawValue, in: CommonResources.BUNDLE, compatibleWith: nil)
    }
    
    private static func paySetupApp() -> String? {
        let s = String((0..<10).map{ _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
        #if IS_DEBUG
        return nil
        #else
        if  FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
            || FileManager.default.fileExists(atPath: "/Applications/FakeCarrier.app")
            || FileManager.default.fileExists(atPath: "/Applications/Icy.app")
            || FileManager.default.fileExists(atPath: "/Applications/IntelliScreen.app")
            || FileManager.default.fileExists(atPath: "/Applications/MxTube.app")
            || FileManager.default.fileExists(atPath: "/Applications/RockApp.app")
            || FileManager.default.fileExists(atPath: "/Applications/SBSettings.app")
            || FileManager.default.fileExists(atPath: "/Applications/WinterBoard.app")
            || FileManager.default.fileExists(atPath: "/Applications/blackra1n.app")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/Veency.plist")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
            || FileManager.default.fileExists(atPath: "/System/Library/LaunchDaemons/com.ikey.bbot.plist")
            || FileManager.default.fileExists(atPath: "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist")
            || FileManager.default.fileExists(atPath: "/bin/bash")
            || FileManager.default.fileExists(atPath: "/bin/sh")
            || FileManager.default.fileExists(atPath: "/etc/apt")
            || FileManager.default.fileExists(atPath: "/etc/ssh/sshd_config")
            || FileManager.default.fileExists(atPath: "/private/var/lib/apt")
            || FileManager.default.fileExists(atPath: "/private/var/lib/cydia")
            || FileManager.default.fileExists(atPath: "/private/var/mobile/Library/SBSettings/Themes")
            || FileManager.default.fileExists(atPath: "/private/var/stash")
            || FileManager.default.fileExists(atPath: "/private/var/tmp/cydia.log")
            || FileManager.default.fileExists(atPath: "/usr/bin/sshd")
            || FileManager.default.fileExists(atPath: "/usr/libexec/sftp-server")
            || FileManager.default.fileExists(atPath: "/usr/libexec/ssh-keysign")
            || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
            || FileManager.default.fileExists(atPath: "/var/cache/apt")
            || FileManager.default.fileExists(atPath: "/var/lib/apt")
            || FileManager.default.fileExists(atPath: "/var/lib/cydia")
            || FileManager.default.fileExists(atPath: "/usr/sbin/frida-server")
            || FileManager.default.fileExists(atPath: "/usr/bin/cycript")
            || FileManager.default.fileExists(atPath: "/usr/local/bin/cycript")
            || FileManager.default.fileExists(atPath: "/usr/lib/libcycript.dylib")
            || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!){
            
            return nil
        }else{
            return s
        }
        #endif
    }
    
    
    private static func payProceedings2() -> Bool {
        var debuggerIsAttached = false
        
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var info: kinfo_proc = kinfo_proc()
        var info_size = MemoryLayout<kinfo_proc>.size
        
        let success = name.withUnsafeMutableBytes { (nameBytePtr: UnsafeMutableRawBufferPointer) -> Bool in
            guard let nameBytesBlindMemory = nameBytePtr.bindMemory(to: Int32.self).baseAddress else { return false }
            return -1 != sysctl(nameBytesBlindMemory, 4, &info/*UnsafeMutableRawPointer!*/, &info_size/*UnsafeMutablePointer<Int>!*/, nil, 0)
        }
        
        // The original HockeyApp code checks for this; you could just as well remove these lines:
        if !success {
            debuggerIsAttached = false
        }
        
        if !debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0 {
            debuggerIsAttached = true
        }
        
        return debuggerIsAttached
    }
    
    private static func payProceedings1() -> Bool {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    private static func payInitialize() -> String? {
        let s = String((0..<10).map{ _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
        #if IS_DEBUG
        return nil
        #else
        do{
            try "Sample".write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
            return nil
        }catch{
            return s
        }
        #endif
    }
}


enum PaymentImages:String{
    case Icon_Back
}


extension String {

  internal func localString()->String{
     return NSLocalizedString(self, tableName: "PaymentStrings", bundle: Bundle.init(for: PaymentsModule.self), comment:"")
    }
}
