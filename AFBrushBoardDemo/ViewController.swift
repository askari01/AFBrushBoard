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

class ViewController: UIViewController, RPBroadcastActivityViewControllerDelegate {
    
    var previewView: UIView!
    var boxView: UIView!
    let myButton: UIButton = UIButton()
    var start = true
    var panGesture = UIPanGestureRecognizer()
    
    // broadcast
    let controller = RPBroadcastController()
    let recorder = RPScreenRecorder.shared()
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(AFBrushBoard(frame:self.view.frame))
        
                
        previewView = UIView(frame: CGRect(x: 20 + self.view.safeAreaInsets.left,
                                           y: 35 + self.view.safeAreaInsets.top,
                                           width: 200,
                                           height: 300))
        previewView.layer.masksToBounds = true
        previewView.clipsToBounds = true
        
        previewView.layer.cornerRadius = 22
        
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.draggedView(_:)))
        previewView.isUserInteractionEnabled = true
        previewView.addGestureRecognizer(panGesture)
        
        self.view.addSubview(previewView)
        
        //Add a view on top of the cameras' view
        boxView = UIView(frame: self.view.frame)
//        boxView.backgroundColor = .lightGray
        
        boxView.layer.cornerRadius = 22
        
        myButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        myButton.backgroundColor = UIColor.red
        myButton.layer.masksToBounds = true
        myButton.setTitle("Start", for: .normal)
        myButton.setTitleColor(UIColor.white, for: .normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width - 80 ,
                                          y: 80)
        myButton.addTarget(self, action: #selector(self.onClickMyButton(sender:)), for: .touchUpInside)
        
//        self.view.addSubview(boxView)
        self.view.addSubview(myButton)
        
        self.setupAVCapture()
        
        // broadcast
        recorder.isMicrophoneEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        previewView.layer.cornerRadius = 22
        previewView.layer.masksToBounds = true
        previewView.clipsToBounds = true
    }
    
    
    @objc
    func draggedView(_ sender: UIPanGestureRecognizer) {
//        self.view.bringSubviewToFront(previewView)
        let translation = sender.translation(in: self.view)
        previewView.center = CGPoint(x: previewView.center.x + translation.x, y: previewView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    override var shouldAutorotate: Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.unknown) {
            return false
        }
        else {
            return true
        }
    }
    
    @objc func onClickMyButton(sender: UIButton){
        print("button pressed")
        // start broadcasting
        if controller.isBroadcasting {
            stopBroadcast()
        } else {
            startBroadcast()
        }
        
        // start recording
//        if start {
//                if RPScreenRecorder.shared().isAvailable {
//                    RPScreenRecorder.shared().isMicrophoneEnabled = true
//                    RPScreenRecorder.shared().startRecording { (error) in
//                        if error == nil { // Recording has started
////                        sender.removeTarget(self, action: "startRecording:", for: .touchUpInside)
////                        sender.addTarget(self, action: "stopRecording:", for: .touchUpInside)
//                            DispatchQueue.main.async {
//                                self.myButton.setTitle("Stop", for: .normal)
//                            }
////                        sender.setTitleColor(UIColor.red, for: .normal)
//                            print ("started")
//                            self.start = false
//                        } else {
//                            // Handle error
//                            self.start = true
//                        }
//                    }
//                } else {
//                    // Display UI for recording being unavailable
//                    print ("not availablir")
//                }
//        } else {
//                RPScreenRecorder.shared().stopRecording { (previewController, error) in
//                    if previewController != nil {
//                        let alertController = UIAlertController(title: "Recording", message: "Do you wish to discard or view your gameplay recording?", preferredStyle: .alert)
//                        
//                        let discardAction = UIAlertAction(title: "Discard", style: .default) { (action: UIAlertAction) in
//                            RPScreenRecorder.shared().discardRecording(handler: { () -> Void in
//                                // Executed once recording has successfully been discarded
//                            })
//                        }
//                        
//                        let viewAction = UIAlertAction(title: "View", style: .default, handler: { (action: UIAlertAction) -> Void in
//                            self.present(previewController!, animated: true, completion: nil)
//                        })
//                        
//                        alertController.addAction(discardAction)
//                        alertController.addAction(viewAction)
//                        
//                        self.present(alertController, animated: true, completion: nil)
//                        
//                        self.start = true
////                        sender.removeTarget(self, action: "stopRecording:", forControlEvents: .TouchUpInside)
////                        sender.addTarget(self, action: "startRecording:", forControlEvents: .TouchUpInside)
//                        DispatchQueue.main.async {
//                            self.myButton.setTitle("Start", for: .normal)
//                        }
////                        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
//                    } else {
//                        // Handle error
//                        self.start = false
//                    }
//                }
//        }
        
    }
    
    func startBroadcast() {
        RPBroadcastActivityViewController.load { (broadcastAVC, error) in
            guard error == nil else {
                print ("cannot load broadcast activity view controller")
                return
            }
            
            if let broadcastAVC = broadcastAVC {
                broadcastAVC.delegate = self
                self.present(broadcastAVC, animated: true, completion: nil)
            }
        }
    }
    
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController,
                                         didFinishWith broadcastController: RPBroadcastController?,
                                         error: Error?) {
        //1
        guard error == nil else {
            print("Broadcast Activity Controller is not available.")
            return
        }
        
        //2
        broadcastActivityViewController.dismiss(animated: true) {
            //3
            broadcastController?.startBroadcast { error in
                //4
                //TODO: Broadcast might take a few seconds to load up. I recommend that you add an activity indicator or something similar to show the user that it is loading.
                //5
                if error == nil {
                    print("Broadcast started successfully!")
                    self.broadcastStarted()
                }
            }
        }
    }
    
    func broadcastStarted() {
        DispatchQueue.main.async {
            self.myButton.setTitle("Stop", for: .normal)
        }
    }
    
    func stopBroadcast() {
        controller.finishBroadcast { error in
            if error == nil {
                print("Broadcast ended")
                self.broadcastEnded()
            }
        }
    }
    
    func broadcastEnded() {
        DispatchQueue.main.async {
            self.myButton.setTitle("Start", for: .normal)
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
