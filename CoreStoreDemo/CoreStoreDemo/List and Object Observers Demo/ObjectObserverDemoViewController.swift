//
//  ObjectObserverDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/06.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


// MARK: - ObjectObserverDemoViewController

class ObjectObserverDemoViewController: UIViewController, ManagedObjectObserver {
    
    var palette: Palette? {
        
        get {
            
            return self.objectController?.object
        }
        set {
            
            if let palette = newValue {
                
                self.objectController = CoreStore.observeObject(palette)
            }
            else {
                
                self.objectController = nil
            }
        }
    }
    
    // MARK: NSObject
    
    deinit {
        
        self.objectController?.removeObserver(self)
    }
    

    // MARK: UIViewController
    
    required init(coder aDecoder: NSCoder) {
        
        if let palette = CoreStore.fetchOne(From(Palette), OrderBy(.Ascending("hue"))) {
            
            self.objectController = CoreStore.observeObject(palette)
        }
        else {
            
            CoreStore.beginSynchronous { (transaction) -> Void in
                
                let palette = transaction.create(Into(Palette))
                palette.setInitialValues()
                
                transaction.commit()
            }
            
            let palette = CoreStore.fetchOne(From(Palette), OrderBy(.Ascending("hue")))!
            self.objectController = CoreStore.observeObject(palette)
        }
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.objectController?.addObserver(self)
        
        if let palette = self.objectController?.object {
            
            self.reloadPaletteInfo(palette, changedKeys: nil)
        }
    }
    
    
    // MARK: ManagedObjectObserver
    
    func managedObjectWillUpdate(objectController: ManagedObjectController<Palette>, object: Palette) {
        
        // none
    }
    
    func managedObjectWasUpdated(objectController: ManagedObjectController<Palette>, object: Palette, changedPersistentKeys: Set<KeyPath>) {
        
        self.reloadPaletteInfo(object, changedKeys: changedPersistentKeys)
    }
    
    func managedObjectWasDeleted(objectController: ManagedObjectController<Palette>, object: Palette) {
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        self.colorNameLabel?.alpha = 0.3
        self.colorView?.alpha = 0.3
        
        self.hsbLabel?.text = "Deleted"
        self.hsbLabel?.textColor = UIColor.redColor()
        
        self.hueSlider?.enabled = false
        self.saturationSlider?.enabled = false
        self.brightnessSlider?.enabled = false
    }

    
    // MARK: Private
    
    var objectController: ManagedObjectController<Palette>?
    
    @IBOutlet weak var colorNameLabel: UILabel?
    @IBOutlet weak var colorView: UIView?
    @IBOutlet weak var hsbLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var hueSlider: UISlider?
    @IBOutlet weak var saturationSlider: UISlider?
    @IBOutlet weak var brightnessSlider: UISlider?
    
    @IBAction dynamic func hueSliderValueDidChange(sender: AnyObject?) {
        
        let hue = self.hueSlider?.value ?? 0
        CoreStore.beginAsynchronous { [weak self] (transaction) -> Void in
            
            if let palette = transaction.edit(self?.objectController?.object) {
                
                palette.hue = Int32(hue)
                transaction.commit()
            }
        }
    }
    
    @IBAction dynamic func saturationSliderValueDidChange(sender: AnyObject?) {
        
        let saturation = self.saturationSlider?.value ?? 0
        CoreStore.beginAsynchronous { [weak self] (transaction) -> Void in
            
            if let palette = transaction.edit(self?.objectController?.object) {
                
                palette.saturation = saturation
                transaction.commit()
            }
        }
    }
    
    @IBAction dynamic func brightnessSliderValueDidChange(sender: AnyObject?) {
        
        let brightness = self.brightnessSlider?.value ?? 0
        CoreStore.beginAsynchronous { [weak self] (transaction) -> Void in
            
            if let palette = transaction.edit(self?.objectController?.object) {
                
                palette.brightness = brightness
                transaction.commit()
            }
        }
    }
    
    @IBAction dynamic func deleteBarButtonTapped(sender: AnyObject?) {
        
        CoreStore.beginAsynchronous { [weak self] (transaction) -> Void in
            
            transaction.delete(self?.objectController?.object)
            transaction.commit()
        }
    }
    
    func reloadPaletteInfo(palette: Palette, changedKeys: Set<String>?) {
        
        self.colorNameLabel?.text = palette.colorName
        
        let color = palette.color
        self.colorNameLabel?.textColor = color
        self.colorView?.backgroundColor = color
        
        self.hsbLabel?.text = palette.colorText
        
        let hue = palette.hue
        let saturation = palette.saturation
        let brightness = palette.brightness
        
        if changedKeys == nil || changedKeys?.contains("hue") == true {
            
            self.hueSlider?.value = Float(palette.hue)
        }
        if changedKeys == nil || changedKeys?.contains("saturation") == true {
            
            self.saturationSlider?.value = palette.saturation
        }
        if changedKeys == nil || changedKeys?.contains("brightness") == true {
            
            self.brightnessSlider?.value = palette.brightness
        }
    }
}
