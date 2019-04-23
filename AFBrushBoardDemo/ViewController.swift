//
//  ViewController.swift
//  AFBrushBoardDemo
//
//  Created by Afry on 16/1/23.
//  Copyright © 2016年 AfryMask. All rights reserved.
//

import UIKit
import ReplayKit
import AVKit

class ViewController: UIViewController {
    
    var previewView: UIView!
    var boxView: UIView!
    let myButton: UIButton = UIButton()
    var start = true
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(AFBrushBoard(frame:self.view.frame))
        
        previewView = UIView(frame: CGRect(x: 20,
                                           y: 35,
                                           width: 200,
                                           height: 300))
        previewView.layer.cornerRadius = 22
        previewView.layer.masksToBounds = true
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        self.view.addSubview(previewView)
        
        //Add a view on top of the cameras' view
        boxView = UIView(frame: self.view.frame)
//        boxView.backgroundColor = .lightGray
        
        boxView.layer.cornerRadius = 22
        
        myButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        myButton.backgroundColor = UIColor.red
        myButton.layer.masksToBounds = true
        myButton.setTitle("Start / Stop", for: .normal)
        myButton.setTitleColor(UIColor.white, for: .normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: previewView.frame.width/1.7, y:290)
        myButton.addTarget(self, action: #selector(self.onClickMyButton(sender:)), for: .touchUpInside)
        
//        self.view.addSubview(boxView)
        self.view.addSubview(myButton)
        
        self.setupAVCapture()
    }
    
    
    override var shouldAutorotate: Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
            UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
            UIDevice.current.orientation == UIDeviceOrientation.unknown) {
            return false
        }
        else {
            return true
        }
    }
    
    @objc func onClickMyButton(sender: UIButton){
        print("button pressed")
        // start recording
        if start {
                if RPScreenRecorder.shared().isAvailable {
                    RPScreenRecorder.shared().isMicrophoneEnabled = true
                    RPScreenRecorder.shared().startRecording { (error) in
                        if error == nil { // Recording has started
//                        sender.removeTarget(self, action: "startRecording:", for: .touchUpInside)
//                        sender.addTarget(self, action: "stopRecording:", for: .touchUpInside)
//                        sender.setTitle("Stop Recording", for: .normal)
//                        sender.setTitleColor(UIColor.red, for: .normal)
                            print ("started")
                            self.start = false
                        } else {
                            // Handle error
                            self.start = true
                        }
                    }
                } else {
                    // Display UI for recording being unavailable
                    print ("not availablir")
                }
        } else {
                RPScreenRecorder.shared().stopRecording { (previewController, error) in
                    if previewController != nil {
                        let alertController = UIAlertController(title: "Recording", message: "Do you wish to discard or view your gameplay recording?", preferredStyle: .alert)
                        
                        let discardAction = UIAlertAction(title: "Discard", style: .default) { (action: UIAlertAction) in
                            RPScreenRecorder.shared().discardRecording(handler: { () -> Void in
                                // Executed once recording has successfully been discarded
                            })
                        }
                        
                        let viewAction = UIAlertAction(title: "View", style: .default, handler: { (action: UIAlertAction) -> Void in
                            self.present(previewController!, animated: true, completion: nil)
                        })
                        
                        alertController.addAction(discardAction)
                        alertController.addAction(viewAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                        self.start = true
//                        sender.removeTarget(self, action: "stopRecording:", forControlEvents: .TouchUpInside)
//                        sender.addTarget(self, action: "startRecording:", forControlEvents: .TouchUpInside)
//                        sender.setTitle("Start Recording", forState: .Normal)
//                        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
                    } else {
                        // Handle error
                        self.start = false
                    }
                }
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
}


// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
extension ViewController:  AVCaptureVideoDataOutputSampleBufferDelegate{
    func setupAVCapture(){
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        guard let device = AVCaptureDevice
            .default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                     for: .video,
                     position: AVCaptureDevice.Position.front) else {
                        return
        }
        captureDevice = device
        beginSession()
    }
    
    func beginSession(){
        var deviceInput: AVCaptureDeviceInput!
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                print("error: cant get deviceInput")
                return
            }
            
            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }
            
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.alwaysDiscardsLateVideoFrames=true
            videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue)
            
            if session.canAddOutput(self.videoDataOutput){
                session.addOutput(self.videoDataOutput)
            }
            
            videoDataOutput.connection(with: .video)?.isEnabled = true
            
            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            let rootLayer :CALayer = self.previewView.layer
            rootLayer.masksToBounds=true
            previewLayer.frame = rootLayer.bounds
            rootLayer.addSublayer(self.previewLayer)
            session.startRunning()
        } catch let error as NSError {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // do stuff here
    }
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
    }
    
}
