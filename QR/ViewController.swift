//
//  ViewController.swift
//  QR
//
//  Created by Žan Skamljič on 17/08/16.
//  Copyright © 2016 Equaleyes. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer!.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession!.startRunning()
        
        view.bringSubviewToFront(messageLabel)
        
        qrCodeFrameView = UIView()
        qrCodeFrameView!.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView!.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        captureSession?.startRunning()
        qrCodeFrameView?.frame = CGRectZero
        messageLabel.text = "No QR Code!"
    }
    
    // MARK: - User Interaction
    
    @IBAction func showCodesTapped(sender: AnyObject) {
        performSegueWithIdentifier("showKeys", sender: nil)
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView!.frame = CGRectZero
            messageLabel.text = "No QR Code!"
            return
        }
        
        let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
        
        if let metadataObj = metadataObj where metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer!.transformedMetadataObjectForMetadataObject(metadataObj) as! AVMetadataMachineReadableCodeObject
            
            qrCodeFrameView!.frame = barCodeObject.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                if let auth = QRAuth(string: metadataObj.stringValue) {
                    auth.save()
                    
                    let alert = UIAlertController(title: "Success!", message: "The QR code is valid!\nThe code is for: \(auth.label)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: showPinScreen))
                    presentViewController(alert, animated: true, completion: nil)
                    
                    captureSession?.stopRunning()
                }
            }
        }
    }
    
    // MARK: - Additional Helpers
    
    func showPinScreen(action: UIAlertAction) {
        performSegueWithIdentifier("showKeys", sender: nil)
    }
}

