//
//  ViewController.swift
//  Health
//
//  Created by 张嘉夫 on 2017/3/3.
//  Copyright © 2017年 张嘉夫. All rights reserved.
//

import UIKit
import HealthKit
import UICircularProgressRing
import LTMorphingLabel

class ViewController: UIViewController {

    let healthManager:HealthManager = HealthManager()
    var activeEnergyBurned: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.makeUI()
            }
        }
    }
    var basalEnergyBurned: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.makeUI()
            }
        }
    }
    var dietaryEnergyConsumed: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.makeUI()
            }
        }
    }
    
    @IBOutlet weak var circularProgressRingView: UICircularProgressRingView!
    @IBOutlet weak var activeEnergyBurnedLabel: LTMorphingLabel!
    @IBOutlet weak var basalEnergyBurnedLabel: LTMorphingLabel!
    @IBOutlet weak var dietaryEnergyConsumedLabel: LTMorphingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.makeUI), name: NSNotification.Name(rawValue: "ReloadData"), object: nil)
        authorizeHealthKit()
        activeEnergyBurnedLabel.morphingEffect = .pixelate
        basalEnergyBurnedLabel.morphingEffect = .pixelate
        dietaryEnergyConsumedLabel.morphingEffect = .pixelate
        
        circularProgressRingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.reloadUI)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeUI() {
        let energyConsumed = dietaryEnergyConsumed-activeEnergyBurned-basalEnergyBurned
        circularProgressRingView.valueIndicator = energyConsumed<0 ? " 大卡 已消耗" : " 大卡 已盈余"
        circularProgressRingView.setProgress(value: CGFloat(Int(abs(energyConsumed))), animationDuration: 2)
        
        self.dietaryEnergyConsumedLabel.text = "膳食 \(Int(self.dietaryEnergyConsumed)) 大卡"
        self.basalEnergyBurnedLabel.text = "静息 \(Int(self.basalEnergyBurned)) 大卡"
        self.activeEnergyBurnedLabel.text = "活动 \(Int(self.activeEnergyBurned)) 大卡"
    }
    
    func reloadUI() {
        circularProgressRingView.setProgress(value: 0, animationDuration: 0)
        self.dietaryEnergyConsumedLabel.text = "膳食 \(0) 大卡"
        self.basalEnergyBurnedLabel.text = "静息 \(0) 大卡"
        self.activeEnergyBurnedLabel.text = "活动 \(0) 大卡"
        
        makeUI()
    }

    func authorizeHealthKit() {
        healthManager.authorizeHealthKit { (authorized, error) in
            if authorized {
                print("HealthKit authorization received.")
                self.loadData()
            }else {
                print("HealthKit authorization denied!")
                if let error = error {
                    print("\(error)")
                }
            }
        }
    }
    
    func loadData() {
        healthManager.readActiveEnergyBurned(completion: { (result) in
            self.activeEnergyBurned = result
        })
        healthManager.readBasalEnergyBurned { (result) in
            self.basalEnergyBurned = result
        }
        healthManager.readDietaryEnergyConsumed { (result) in
            self.dietaryEnergyConsumed = result
        }
    }
}

