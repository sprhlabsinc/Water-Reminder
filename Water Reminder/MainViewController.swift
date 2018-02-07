//
//  ViewController.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 12/30/14.
//  Copyright (c) 2014 Suwao Ltd (suwao.com). All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


#if PREMIUM
    class BaseViewController: UIViewController{}
    #else
    class BaseViewController: ADViewController{}
#endif

class MainViewController: BaseViewController, UIGestureRecognizerDelegate, SUKeyboardViewDelegate, UIAlertViewDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: SUWeekGraph!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var circleView: SUCircleBar!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var consumedLabel: UILabel!
    @IBOutlet weak var remainsLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var data1Label: UILabel!
    @IBOutlet weak var data2Label: UILabel!
    @IBOutlet weak var data3Label: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var notificationsButton: UIButton!

    var menuView: SUMenuView?
    var initialized: Bool = false
    var indexPath: IndexPath?
    var keyboard: SUKeyboardView?
    var collectionItem = SUCollectionItem()
    let viewTransitionDelegate = SUTransitionDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        FAKE DATES
//        deleteEntity("Statistics")
//        for i in 1...9 {
//            let f = Float(arc4random()) / 0xFFFFFFFF
//            let object = NSEntityDescription.insertNewObjectForEntityForName("Statistics", inManagedObjectContext: context) as! Statistics
//            object.date = shift(Double(-i))
//            object.amount = NSNumber(float: 2000.0 + 800.0 * f)
//            try! context.save()
//        }
//        fontList()
        
//        self.navigationController?.navigationBar.barTintColor = colors[2]
        self.view.backgroundColor = colors[0]
        self.topView.backgroundColor = colors[0]
        self.bottomView.backgroundColor = colors[0]
        self.middleView.backgroundColor = colors[2]
        
        self.circleView.backgroundColor = colors[0]
        self.circleView.barBorderColor = colors[1]
        self.circleView.barColor = colors[2]
        self.circleView.barBackgroundColor = colors[3]
        
        let labels = [self.data1Label, self.data2Label, self.data3Label, self.targetLabel, self.consumedLabel, self.remainsLabel, self.activityLabel]
        var captions = ["0.00L", "DAILY GOAL", "CONSUMED", "REMAINS", "Last activity: none"]
        for (index, label) in labels.enumerated() {
            label?.font = index == 6 ? fonts[3] : fonts[index < 3 ? 5 : 3]
            label?.text = captions[index < 3 ? 0 : index - 2]
            label?.textColor = colors[index < 3 ? 2 : 7]
        }
        self.mainLabel.text = "0.00L"
        self.mainLabel.font = fonts[2]
        self.mainLabel.textColor = colors[7]
        
        self.activityLabel.textColor = colors[0]
        
        if self.bottomView.bars != nil {
            for (index, bar) in (self.bottomView.bars!).enumerated() {
                bar.backgroundView.backgroundColor = colors[3]
                bar.indicatorView.backgroundColor = colors[8]
                bar.data0Label.font = fonts[4]
                bar.data1Label.font = fonts[4]
                bar.data0Label.backgroundColor = colors[3]
                bar.data1Label.backgroundColor = colors[6]
                bar.data1Label.text = weekdays[index]
            }
        }
        self.bottomView.caps(colors[3], borderColor: colors[5], borderWidth: 4.0)
        self.notificationsButton.tintColor = colors[4]
        self.doNotifications(nil)
        Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(MainViewController.update), userInfo:nil, repeats:true)
        titleLabelWithItem(self.navigationBar.items![0])
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.applicationWillEnterForeground), name: NSNotification.Name(rawValue: "willEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.applicationWillResignActive), name: NSNotification.Name(rawValue: "willResignActive"), object: nil)
        
        #if !PREMIUM
            if !settings!.pro.boolValue {
                delay(ad_interval / 2, closure: {
                    self.runInterstitialAd()
                })
            }
        #endif
    }
    
    func applicationWillEnterForeground() {
        #if !PREMIUM
            if !settings!.pro.boolValue {
                delay(ad_interval / 4, closure: {
                    self.runInterstitialAd()
                })
            }
        #endif
    }
    func applicationWillResignActive() {
        #if !PREMIUM
            if !settings!.pro.boolValue {
                self.stopInterstitialAd()
            }
        #endif
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.initialized {
            self.initialized = true
            if self.bottomView.bars != nil {
                for bar in self.bottomView.bars! {
                    bar.indicatorViewHeight.constant = bar.capView!.frame.width / 2
                }
            }
            self.bottomView.adjust()
            self.bottomView.needsUpdateConstraints()
            self.bottomView.layoutIfNeeded()
            self.infoUpdate()
        }
    }
    
    @IBAction func doLeftMenu(_ sender: AnyObject) {
        self.showMwnu(right: false)
    }
    
    @IBAction func doRightMenu(_ sender: AnyObject) {
        self.showMwnu(right: true)
    }
    
    @IBAction func doNotifications(_ sender: AnyObject?) {
        if sender != nil {
            settings!.reminders = NSNumber(value: !settings!.reminders.boolValue as Bool)
            do {
                try context.save()
            } catch _ {
            }
            updateNotifications()
        }
        self.notificationsButton.setImage(UIImage(named: (settings!.reminders.boolValue ? "NotificationsOn" : "NotificationsOff")), for: UIControlState())
    }
    
    func showMwnu(right: Bool) {
        if self.menuView == nil {
            self.menuView = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)?.first as? SUMenuView
            if self.menuView != nil {
                self.menuView!.frame = self.view.frame
                self.menuView!.reload(alt: right)
                self.menuView!.menuTableView.backgroundColor = colors[0] // UIColor(patternImage: UIImage(named: "MenuBackground")!)
                self.menuView!.backgroundColor = UIColor.white.withAlphaComponent(0)
                self.view.addSubview(self.menuView!)
                self.menuView!.tableViewLeadingSpace.constant = right ? self.view.frame.width : -abs(self.menuView!.tableViewWidth.constant)
                self.menuView!.needsUpdateConstraints()
                self.menuView!.layoutIfNeeded()
                
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.closeMenu(_:)))
                gestureRecognizer.delegate = self
                self.menuView!.addGestureRecognizer(gestureRecognizer)
                
                self.menuView!.tableViewLeadingSpace.constant = right ? self.view.frame.width - abs(self.menuView!.tableViewWidth.constant) : 0
                
                self.menuView!.controller = self
//                self.menuView!.menuTableView.reloadData()
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                    self.menuView!.backgroundColor = UIColor.black.withAlphaComponent(0.65)
                    self.menuView!.needsUpdateConstraints()
                    self.menuView!.layoutIfNeeded()
                    },
                    completion: nil)
            }
        } else {
            self.closeMenu(nil)
        }
    }
    
    func closeMenu(_ sender: AnyObject?) {
        if self.menuView != nil {
            let alt = self.menuView!.isAlt()
            self.menuView!.tableViewLeadingSpace.constant = self.menuView!.tableViewLeadingSpace.constant == 0 ? -self.menuView!.tableViewWidth.constant : self.view.frame.width
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                self.menuView!.backgroundColor = UIColor.black.withAlphaComponent(0)
                self.menuView!.layoutIfNeeded()
                }, completion: { _ in
                    self.menuView?.removeFromSuperview()
                    self.menuView = nil
                    if sender != nil {
                        if sender is IndexPath {
                            let indexPath = sender as! IndexPath
                            if alt == true {
                                var collection = getCollection()
                                let section = indexPath.section + ((collection?.count == 0 && indexPath.section > 0) ? 1 : 0)
                                switch (section) {
                                case 0:
                                    switch (indexPath.row) {
                                    case 0:
                                        showKeyboard(self.keyboard, controller: self, delegate: self, title: "Add Custom Amount", suffix: format(nil, liquid: true, imperial: settings!.units.boolValue, short: false), tag: SUKeyboardViewTag.add)
                                    case 1:
                                        self.add(settings!.recent.floatValue)
                                    default:
                                        break
                                    }
                                case 1:
//                                    if collection?.count <= indexPath.row {
                                        self.add(collection![indexPath.row].amount.floatValue)
//                                    }
                                case 2:
                                    switch (indexPath.row) {
                                    case 0:
                                        let statistics = getStatistics()
                                        if statistics != nil {
                                            let object = statistics!.last
                                            redo.append([object!.amount.floatValue, object!.date] as AnyObject)
                                            context.delete(object!)
                                            do {
                                                try context.save()
                                            } catch _ {
                                            }
                                            self.infoUpdate()
                                        }
                                    case 1:
                                        if redo.count > 0 {
                                            let object = redo.last as! NSArray
                                            self.add(object[0] as! Float, date: object[1] as? Date)
                                            redo.removeLast()
                                        }
                                    default:
                                        break
                                    }
                                default:
                                    break
                                }
                            } else {
                                self.performSegue(withIdentifier: "options", sender: self)
                            }
                        }
                    }
            })
        }
    }
    
    func tableCellTouched(_ indexPath: IndexPath) {
        self.indexPath = indexPath
        self.closeMenu(indexPath as AnyObject?)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "options" {
            let controller = segue.destination as! FirstTableViewController
            if self.indexPath != nil {
                
                #if PREMIUM
                    let i = self.indexPath!.row + ((self.indexPath!.row > 3) ? 1 : 0)
                    #else
                    let i = self.indexPath!.row
                #endif
                
                switch (i) {
                case 0:
                    controller.type = .settings
                case 1:
                    controller.type = .collection
                case 2:
                    controller.type = .calculator
                case 3:
                    controller.type = .notifications
                case 4:
                    controller.type = .upgrades
                default:
                    controller.type = .feedback
                }
            }
//            controller.transitioningDelegate = viewTransitionDelegate
//            controller.modalPresentationStyle = .Custom
        }
    }
    
    // MARK: - TIMER
    func update() {
        if settings!.stamp != shift(0){
            print("Update")
            settings!.stamp = shift(0)
            do {
                try context.save()
            } catch _ {
            }
            infoUpdate()
        } else {
            infoUpdate(true)
        }
    }
    
    // MARK: - GESTURE RECOGNIZER
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.menuView
    }
    
    // MARK: - KEYBOARD
    func keyboard(_ sender: SUKeyboardView, shouldClose done: Bool) {
        if settings != nil {
            let value = (sender.strip() as NSString).doubleValue
            print("Closing keyboard: \(value)")
            if value > 0 {
                if sender.keyboardTag == .add {
                    let limit = MAX_LIQUID[settings!.units.intValue]
                    if value > limit {
                        messageLessOrEqual(self, value: Int(limit))
                        return
                    }
                }
                if sender.keyboardTag == .add {
                    settings!.recent = NSNumber(value: simplify(value) as Double)
                    do {
                        try context.save()
                    } catch _ {
                    }
                    self.add(Float(value))
                }
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 0
            }, completion: { _ in
                sender.removeFromSuperview()
        })
    }
    
    func keyboard(_ sender: SUKeyboardView, willChangeValue value: String) -> Bool {
//        if keyboard!.keyboardTag == .Age {
//            let range = value.rangeOfString(".")
//            let age = range != nil ? value.substringToIndex(range!.startIndex) : value
//            keyboard!.suffix = age2string(age.toInt()!).suffix
//        }
        return true
    }
    
    // MARK: - MAIN VIEW
    func infoUpdate(_ activity: Bool = false) {
        let statistics = getStatistics()
        if !activity {
            var data = [Int : Float]()
            var days = [Int]()
            var values = [Float]()
            for index in 0...6 {
                let day = shift(Double(-index))
                for object in statistics! {
                    if day.compare(shift(0, date: object.date)) == ComparisonResult.orderedSame {
                        let i = weekday(object.date) - 1
                        data[i] = data[i] == nil ? object.amount.floatValue : data[i]! + object.amount.floatValue
                        days.append(i)
                        values.append(data[i]!)
                    }
                }
            }
            
            let limit = Float(MAX_LIQUID[settings!.units.intValue])
            let today = shift(0)
            let dayMax = days.reduce(Int.min, { max($0, $1) })
            var liquidMax = values.reduce(0, { max($0, $1) })
            liquidMax = min(limit, max(liquidMax, settings!.goal.floatValue))
            let i = weekday(Date()) - 1
            let consumed = min(limit, (data[i] ?? 0))
            let percent = CGFloat(consumed / settings!.goal.floatValue) 
            let result = Float(100.0 * percent)
            self.mainLabel.text = String(format: "%.0f %%", result)
            self.circleView.progress(percent)
            for (index, bar) in (self.bottomView.bars!).enumerated() {
                var i = index
                if weekday(today) <= dayMax {
                    let day = shift(Double(-6 + index))
                    i = weekday(day) - 1
                    bar.data1Label.text = weekdays[i]
                }
                bar.data1Label.textColor = i == 0 ? colors[9] : colors[0]
                
                bar.markerView.backgroundColor = i == (weekday(today) - 1) ? colors[9] : bar.data1Label.backgroundColor
                
                let value = min(limit, (data[i] ?? 0))
                let percent = CGFloat(value / liquidMax)
                bar.data0Label.text = format(NSNumber(value: simplify(Double(value)) as Double), liquid: true, imperial: settings!.units.boolValue, short: true, fraction: settings!.units.boolValue ? 0 : 2)
                bar.position(percent)
            }
            let goal = settings!.goal.floatValue
            self.data1Label.text = format(settings!.goal, liquid: true, imperial: settings!.units.boolValue, short: true, fraction: settings!.units.boolValue ? 0 : 2)
            self.data2Label.text = format(simplify(Double(consumed)) as NSNumber?, liquid: true, imperial: settings!.units.boolValue, short: true, fraction: settings!.units.boolValue ? 0 : 2)
            let left = simplify(Double(consumed < goal ? goal - consumed : 0.0))
            self.data3Label.text = format(left as NSNumber?, liquid: true, imperial: settings!.units.boolValue, short: true, fraction: settings!.units.boolValue ? 0 : 2)
        }
        
        if statistics?.count > 0 {
            let object = statistics![statistics!.count - 1]
//                        println("Obj: \(object)")
            activityLabel.text = "LAST ACTIVITY: " + lastActivityWithStartDate(object.date)
//            println("LA: \(title)")
        }
    }
    
    func add(_ value: Float, date: Date? = nil) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: context) as! Statistics
        object.date = date ?? Date()
        object.amount = NSNumber(value: value as Float)
        settings!.recent = NSNumber(value: value as Float)
        do {
            try context.save()
        } catch _ {
        }
        if date == nil {
            redo.removeAll(keepingCapacity: false)
        }
        self.infoUpdate()
    }
    
}

