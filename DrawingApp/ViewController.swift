//
//  ViewController.swift
//  DrawingApp
//
//  Created by Parveen kumar on 31/10/2019 .
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    
    let canvasWidth: CGFloat = 768
    let canvarOverscrollingHeight: CGFloat = 300
    
    var drawing = PKDrawing()
    var toolPicker: PKToolPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput
        
        // Set up the tool picker
        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            // Set up the tool picker, using the window of our parent because our view has not
            // been added to a window yet.
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }

    @IBAction func saveDrwaingToCameraRoll(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil{
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: { success, error in
                //deal with success or error
            })
        }
    }
    
    @IBAction func togleFingerOrPencil(_ sender: Any) {
        canvasView.drawingPolicy = .anyInput
//        pencilFingerButton.title = canvasView.drawingPolicy.rawValue ? "Finger" : "Pencil"
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
    
    func updateContentSizeForDrawing(){
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        if !drawing.bounds.isNull{
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvarOverscrollingHeight) * canvasView.zoomScale)
        }else{
            contentHeight = canvasView.bounds.height
        }
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
    }
    
}

