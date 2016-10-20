//
//  PhotoViewController.swift
//  mosaic
//
//  Created by Divine Grace on 18/10/16.
//  Copyright © 2016 Divine Grace. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var menuBar : UIView!
    @IBOutlet weak var settingsView : UIView!
    @IBOutlet weak var menuView : UIView!
    @IBOutlet weak var slider : UISlider!
    @IBOutlet weak var sliderValueLabel : UILabel!
    @IBOutlet weak var currentTileDimensionLabel : UILabel!
    @IBOutlet weak var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mosaicViewContainer: UIView!

    private let imagePicker = UIImagePickerController()
    
    private var currentTileDimension = 32.0
    private var mosaicViewController : MosaicViewController?
    
    //MARK: - 

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        menuBar.layer.cornerRadius = 10.0
        
        settingsView.layer.borderColor = UIColor.lightGray.cgColor
        settingsView.layer.borderWidth = 1.0
        settingsView.layer.cornerRadius = 10.0
        
        self.slider.value = Float(currentTileDimension)
        let value = Int(currentTileDimension)
        self.currentTileDimensionLabel.text = "Tile Dimension: " + String(value) + " x " + String(value)
        self.sliderValueLabel.text = "Tile Dimension: " + String(value) + " x " + String(value)
        closeDimensionSettingView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMosaicView" {
            if let dest = segue.destination as? MosaicViewController {
               self.mosaicViewController = dest
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func uploadLocalImage(sender:AnyObject?){
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func approveDimensionSetting(sender:AnyObject?){
        closeDimensionSettingView()
        currentTileDimension = Double(self.slider.value)
        let value = Int(currentTileDimension)
        self.currentTileDimensionLabel.text = "Tile Dimension: " + String(value) + " x " + String(value)
    }
    
    @IBAction func cancelDimensionSetting(sender:AnyObject?){
        closeDimensionSettingView()
        slider.value = Float(currentTileDimension)
        let value = Int(currentTileDimension)
        self.sliderValueLabel.text = "Tile Dimension: " + String(value) + " x " + String(value)
    }
    
    @IBAction func showSettings(sender:AnyObject?){
        self.menuView.isUserInteractionEnabled = false
        self.menuView.alpha = 0.5
        UIView.animate(withDuration: 2) {
            self.settingsView.isHidden = false
            self.menuViewHeightConstraint.constant = 160.0
        }
    }
    
    @IBAction func revertToRawImage(sender:AnyObject?){
        if mosaicViewController != nil {
            menuBar.alpha = 0.5
            menuBar.isUserInteractionEnabled = false
            mosaicViewContainer.isHidden = true
            self.scrollView.isHidden = false
        }
    }
    
    @IBAction func splitImage(sender:AnyObject?){
        if mosaicViewController != nil {
            mosaicViewContainer.isHidden = false
            self.scrollView.isHidden = true
            menuBar.alpha = 0.5
            menuBar.isUserInteractionEnabled = false
            
            mosaicViewController!.convertImageToPhotoMosaic(newImage: self.imageView.image!, tilesize:Double(currentTileDimension)){() -> Void in
                self.menuBar.alpha = 1.0
                self.menuBar.isUserInteractionEnabled = true
            }
        }
    }
    
    @IBAction func sliderChangedValue(sender:AnyObject?){
        if let slider = sender as? UISlider {
            let value = Int(slider.value)
            sliderValueLabel.text = "Tile Dimension: " + String(value) + " x " + String(value)
        }
    }
    
    @IBAction func hideUnhideMenuBar(sender:AnyObject?){
        self.menuBar.isHidden = !self.menuBar.isHidden
    }
    
    
    //MARK: - Private Methods

    private func closeDimensionSettingView(){
        self.menuView.isUserInteractionEnabled = true
        self.menuView.alpha = 1.0
        UIView.animate(withDuration: 2) {
            self.settingsView.isHidden = true
            self.menuViewHeightConstraint.constant = 70.0
        }
    }
    
    
    @objc(viewForZoomingInScrollView:) func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //MARK: - UIImagePickerControllerDelegate Methods
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if mosaicViewController != nil {
                mosaicViewContainer.isHidden = true
                self.scrollView.isHidden = false
            }
            self.imageView.image = selectedImage
            self.imageView.contentMode = .scaleAspectFit
            
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    private func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}


