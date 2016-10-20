//
//  MosaicViewController.swift
//  mosaic
//
//  Created by Divine Grace on 18/10/16.
//  Copyright © 2016 Divine Grace. All rights reserved.
//

import UIKit
import TakeHomeTask


class MosaicViewController: UIViewController {
    
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var activityIndicatorView : UIActivityIndicatorView!
    
    private var image : UIImage?
    private var completionHandler:(() -> Void)?
    
    let mosaicTileServer = MosaicTileServer()
    
    //MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Public Function

     func convertImageToPhotoMosaic(newImage: UIImage, tilesize:Double, completionHandler:(() -> Void)?){
        
        self.completionHandler = completionHandler
        self.image = newImage
        
        //show activity indicator while processing the image
        self.activityIndicatorView.startAnimating()

        //remove all the previous added tile layers
        if imageView.layer.sublayers != nil && (imageView.layer.sublayers?.count)! > 0 {
            for layer in imageView.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        
        //make sure to resize the content of the scrollview enoough for the incoming tile images
        self.scrollView.contentSize = image!.size
        
        //set scrollView zoom scale to see big area of image tile progression
        self.scrollView.zoomScale = 1  //default zoom
        let imageMaxDimension = max((self.image?.size.width)!, (self.image?.size.height)!)
        let scrollViewMaxDimension = max((self.scrollView?.bounds.size.width)!, (self.scrollView?.bounds.size.height)!)
        
        if imageMaxDimension > scrollViewMaxDimension {
            self.scrollView.zoomScale =  scrollViewMaxDimension / imageMaxDimension
        }
        
        
        /******* Splitting Image *****/
        
        //call this handler when tile layer is created
        let tileCompletionHandler = {(_ tileLayer:CALayer?) -> Void in
            self.imageView.layer.addSublayer(tileLayer!)
            }
        
        //call this handler when task is completely done
        let taskCompletionHandler = {() -> Void in
            self.activityIndicatorView.stopAnimating()
            if self.completionHandler != nil {
                self.completionHandler!()
            }
        }

        //now start splitting the image
        splitImage(image: newImage, tileSize: tilesize,
                                  tileCompletionHandler:tileCompletionHandler,
                                  taskCompletionHandler:taskCompletionHandler)
       
    }
    
    
    //MARK: - Private
    func splitImage(image: UIImage, tileSize: Double,
                    tileCompletionHandler:((_ tileLayer:CALayer?) -> Void)?,
                    taskCompletionHandler:(() -> Void)? )
    {
        
        var x = 0, y = 0
        
        //create serial queue per row
        var serialQueue = DispatchQueue(label: "com.mosaic.lineNo\(y)")
        
        //create single context to save memory
        let context = CIContext(options:nil)
        
        //create single cgImage to save memory
        let cgImage = image.cgImage
        
        let rows = Int(image.size.width) / Int(tileSize)
        let columns = Int(image.size.height) / Int(tileSize)
        let totalExpectedTiles : Int = rows * columns
        
        for index in 0..<totalExpectedTiles {
            let rect:CGRect = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(tileSize), height: CGFloat(tileSize))
            
            serialQueue.async {
                let averageColor : UIColor? = MosaicHelper.getAverageColorInRectOfImage(context:context, image: (cgImage)!, rect:rect)
                
                if averageColor == nil {
                    
                    //show an alert telling the error
                    let alert = UIAlertController(title: "Error", message: "There is a problem encounterd in getting the area average color. Please check image or select a smaller image.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default){(UIAlertAction) -> Void in
                        taskCompletionHandler!()
                    })
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.downloadTile(rect: rect, color: averageColor!){ (tileLayer:CALayer?) -> Void in
                        if tileCompletionHandler != nil && tileLayer != nil{
                            tileCompletionHandler!(tileLayer)
                        }
                        
                        if (index + 1) == totalExpectedTiles  && taskCompletionHandler != nil{
                            taskCompletionHandler!()
                        }
                    }
                }
            }
            
            x = x + Int(tileSize)
            //check for next row
            if (x + Int(tileSize)) > Int(image.size.width) {
                x = 0
                y = y + Int(tileSize)
                serialQueue = DispatchQueue(label: "com.mosaic.lineNo\(y)")
            }
        }
        
    }
    
    
    //download tile with specified color and add the tile to a specific rect in the imageview.
    private func downloadTile(rect: CGRect, color: UIColor,  tileCompletionHandler:((_ tileLayer:CALayer?) -> Void)?)
    {
        let _ = mosaicTileServer.fetchTile(for: color, size: rect.size,
                                           success: {  (newImage) in
                                            
                                            DispatchQueue.main.async {
                                                if tileCompletionHandler != nil {
                                                    let aLayer = CALayer()
                                                    aLayer.frame = rect
                                                    aLayer.contents = newImage.cgImage
                                                    tileCompletionHandler!(aLayer)
                                                }
                                            }
                                            
            }, failure: { (error) in
                print(error)
                
                //show an alert telling the error
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                if tileCompletionHandler != nil {
                    tileCompletionHandler!(nil)
                }
                
        })
    }
    
    
    //this will handle the zooming effect of the scrollview
    @objc(viewForZoomingInScrollView:) func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}




