//
//  FirstTableViewController.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 4/5/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import UIKit
import MessageUI
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


#if PREMIUM
    class BaseTableViewController: UIViewController{}
    #else
    class BaseTableViewController: IAPViewController{}
#endif

class FirstTableViewController: BaseTableViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, SUKeyboardViewDelegate  {
    
    var type: SUTableType?
    var list = NSArray()
    var index: Int?
    var keyboard: SUKeyboardView?
    let viewTransitionDelegate = SUTransitionDelegate()
    var collection: [Collection]?
    var notifications: [Notifications]?
    var indicator: UIActivityIndicatorView?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var index: Int?
        if self.type != nil {
            switch type! {
            case .settings:
                index = 0
            case .collection:
                index = 1
            case .calculator:
                index = 2
            case .notifications:
                index = 3
            case .upgrades:
                index = 4
            case .feedback:
                index = 5
            default:
                index = nil
            }
        }
        if index != nil {
            self.addButton.isEnabled = false
            self.addButton.tintColor = UIColor.clear
            if let path = Bundle.main.path(forResource: "Options", ofType: "plist") {
//                let array = NSMutableArray(contentsOfFile: path)
                self.list = (NSArray(contentsOfFile: path)![index!] as! NSArray)[2] as! NSArray
                let label = titleLabel()
                label.text = ((NSArray(contentsOfFile: path)![index!] as! NSArray)[0] as? String)?.capitalized
                label.font = fonts[1]
                self.navigationBar.items![0].titleView = label
                label.sizeToFit()
            }
            if self.type == .collection || self.type == .notifications {
                self.addButton.isEnabled = true
                self.addButton.tintColor = self.navigationBar.barTintColor
            }
        }
        
        if #available(iOS 8.0, *) {
            self.tableView.layoutMargins = UIEdgeInsets.zero
        }
        self.tableView.isOpaque = false
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundView?.backgroundColor = colors[0]
        self.tableView.backgroundColor = colors[0]
        self.tableView.separatorColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.isEditing = false
    }
    
    @IBAction func doBack(_ sender: AnyObject) {
        let controller = self.presentingViewController as! MainViewController
        controller.infoUpdate()
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func doAdd(_ sender: AnyObject) {
        if self.type == .collection || self.type == .notifications {
            self.index = nil
            performSegue(withIdentifier: "data", sender: self)
        }
    }
    
    func doRecommended() {
        if settings != nil {
            settings!.goal = NSNumber(value: Float(calculate()) as Float)
            do {
                try context.save()
            } catch _ {
            }
            doBack(self)
        }
    }
    
    func reload() {
        if self.type == .collection {
            self.collection = getCollection()
        } else if self.type == .notifications {
            self.notifications = getNotifications()
        }
        self.tableView.reloadData()
    }
    
    // MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44 //tableView == settingsTable ? factor(46.0) : 0//factor(32.0)
    }
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 38 //factor(46.0)
    //    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //tableView == settingsTable ? settings_content.count : 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.type == .collection || self.type == .notifications
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            tableView.beginUpdates()
            if self.type == .collection {
                let objects = getCollection()
                if objects != nil {
                    if objects!.count >= indexPath.row {
                        context.delete(objects![indexPath.row])
                    }
                }
            } else if self.type == .notifications {
                let objects = getNotifications()
                if objects?.count >= indexPath.row {
                    context.delete(objects![indexPath.row])
                    updateNotifications()
                }
            }
            do {
                try context.save()
            } catch _ {
            }
            self.reload()
            tableView.deleteRows(at: [indexPath], with:.fade)
            tableView.endUpdates()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.type == .collection {
            return (self.collection != nil ? self.collection!.count : 0)
        } else if self.type == .notifications {
            return (self.notifications != nil ? self.notifications!.count : 0)
        }
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //            var label = SULabel(frame: CGRectZero, edgeInsets: UIEdgeInsetsMake(factor(16.0), factor(12.0), 0, 0))
        //            label.text = settings_content[section][0].uppercaseString
        //            label.font = font_table_header
        //            return label
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: id(indexPath))
        var title: String?
        var detail: String? = nil
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        cell.accessoryView = nil
        cell.accessoryType = .none
        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
        if self.collection != nil {
            title = self.collection![indexPath.row].name
            detail = format(self.collection![indexPath.row].amount, liquid: true, imperial: settings!.units.boolValue, short: false)
        } else if self.notifications != nil {
            title = self.notifications![indexPath.row].label
            detail = timeFromDate(self.notifications![indexPath.row].date)
        } else {
            if let array = list[indexPath.row] as? NSArray {
                title = array[0] as? String
                detail = array[1] as? String
            }
        }
        
        switch self.type! {
        case .settings:
            switch indexPath.row {
            case 0:
                if settings != nil {
                    detail = format(settings!.goal.floatValue as NSNumber?, liquid: true, imperial: settings!.units.boolValue, short: false, fraction: 0, spaced: true)
                }
            case 1:
                if settings != nil {
                    if let array = (list[indexPath.row] as! NSArray)[2] as? NSArray {
                        detail = (array[settings!.units.intValue] as! NSArray)[0] as? String
                    }
                }
            case 2:
                let object = UISwitch()
                object.tintColor = colors[2]
                object.onTintColor = colors[2]
                object.thumbTintColor = colors[0]
                object.backgroundColor = colors[2]
                object.layer.cornerRadius = 16
                object.addTarget(self, action: #selector(FirstTableViewController.doNotificationsEnabled(_:)), for: .valueChanged)
                object.isOn = settings?.reminders.boolValue ?? false
                cell.accessoryView = object
                cell.selectionStyle = .none
                detail = self.notificationsTitle()
            case 3:
                if let array = (list[indexPath.row] as! NSArray)[2] as? NSArray {
                    detail = (array[settings!.sound.intValue] as! NSArray)[0] as? String
                }
            default:
                break
            }
        case .calculator:
            switch indexPath.row {
            case 0:
                if let array = (list[indexPath.row] as! NSArray)[2] as? NSArray {
                    if array.count > 1 {
                        detail = (array[settings!.gender.intValue] as! NSArray)[0] as? String
                    }
                }
            case 1:
                detail = age2string(settings!.age.intValue).full
            case 2:
                detail = format(NSNumber(value: settings!.weight.floatValue as Float), liquid: false, imperial: settings!.units.boolValue, short: false, fraction: 2, spaced: true)
            case 3:
                detail = format(NSNumber(value: Float(calculate()) as Float), liquid: true, imperial: settings!.units.boolValue, short: false, fraction: 0, spaced: true)
                let height = cell.frame.size.height - 8
                let button = UIButton(type: .system)
                button.frame = CGRect(x: 0, y: 4, width: 64, height: height - 4)
                button.layer.cornerRadius = 4.0
                button.setTitle("Apply", for: UIControlState())
                button.setTitleColor(colors[0], for: UIControlState())
                button.backgroundColor = colors[2]
                button.addTarget(self, action: #selector(FirstTableViewController.doRecommended), for: .touchUpInside)
                cell.accessoryView = button
            default:
                break
            }
        case .collection:
            if let item = self.collection?[indexPath.row] {
                title = item.name
                detail = format(NSNumber(value: item.amount.floatValue as Float), liquid: true, imperial: settings!.units.boolValue, short: false, fraction: 0, spaced: true)
            }
        case .notifications:
            if let item = self.notifications?[indexPath.row] {
                title = item.label
                detail = timeFromDate(item.date)
            }
        case .feedback:
            switch indexPath.row {
            case 1:
                title = String(format: title!, app_shortname)
            default:
                break
            }
        default:
            break
        }
        
        if self.collection == nil && self.notifications == nil {
            if let array = list[indexPath.row] as? NSArray {
                if array.count > 2 {
                    cell.accessoryView = imageView("DisclosureIndicator", tintColor: colors[2])
                }
            }
        }
        
        cell.textLabel?.font = fonts[1]
        cell.textLabel?.textColor = colors[5]
        cell.textLabel?.text = title
        
        cell.detailTextLabel?.font = fonts[6]
        cell.detailTextLabel?.textColor = colors[5]
        cell.detailTextLabel?.text = detail
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.index = indexPath.row
        switch self.type! {
        case .settings:
            switch indexPath.row {
            case 0:
                // DAILY GOAL
                if let array = list[indexPath.row] as? NSArray {
                    showKeyboard(self.keyboard, controller: self, delegate: self, title: array[0] as! String, suffix: format(nil, liquid: true, imperial: settings!.units.boolValue, short: false), tag: SUKeyboardViewTag.goal)
                }
            case 1:
                performSegue(withIdentifier: "data", sender: self)
            case 3:
                performSegue(withIdentifier: "data", sender: self)
            default:
                break
            }
        case .collection:
            performSegue(withIdentifier: "data", sender: self)
        case .calculator:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "data", sender: self)
            case 1:
                if let array = list[indexPath.row] as? NSArray {
                    showKeyboard(self.keyboard, controller: self, delegate: self, title: array[0] as! String, suffix: age2string(0).suffix, tag: SUKeyboardViewTag.age)
                }
            case 2:
                if let array = list[indexPath.row] as? NSArray {
                    showKeyboard(self.keyboard, controller: self, delegate: self, title: array[0] as! String, suffix: " " + format(nil, liquid: false, imperial: settings!.units.boolValue, short: false), tag: SUKeyboardViewTag.weight)
                }
            default:
                break
            }
        case .notifications:
            performSegue(withIdentifier: "data", sender: self)
        case .upgrades:
            #if !PREMIUM
                switch indexPath.row {
                case 0:
                // BUY PRODUCT
                    showActivityIndicator(&indicator, view: self.view)
                    buyProduct(default_pid)
                case 1:
                // RESTORE
                    showActivityIndicator(&indicator, view: self.view)
                    restorePurchases()
                default:
                    break
                }
            #endif
        case .feedback:
            // FEEDBACK
            switch indexPath.row {
            case 0:
                // EMAIL
                if !MFMailComposeViewController.canSendMail() {
                    alert(self, title: "Error", message: "Device is unable to send email in its current state", tag: 0)
                } else {
                    let messageController = MFMailComposeViewController()
                    messageController.mailComposeDelegate = self
                    messageController.setSubject(app_fullname)
                    messageController.setToRecipients([support_email])
                    let text = String(format: "\n\nDevice: %@\niOS Version: %@\nApp Executable: %@\nApp Version: %@", device(), UIDevice.current.systemVersion, app_executable, app_version)
                    messageController.setMessageBody(text, isHTML:false)
                    self.present(messageController, animated:true, completion:nil)
                }
            case 1:
                // RATE
                open([itunes_url])
            case 2:
                // FACEBOOK
                open(facebook_urls)
            case 3:
                // TWITTER
                open(twitter_urls)
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK: - KEYBOARD
    func keyboard(_ sender: SUKeyboardView, shouldClose done: Bool) {
        if settings != nil {
            let value = (sender.strip() as NSString).doubleValue
            if value > 0 {
                if sender.keyboardTag == .goal {
                    let limit = MAX_LIQUID[settings!.units.intValue]
                    if value > limit {
                        messageLessOrEqual(self, value: Int(limit))
                        return
                    }
                    settings!.goal = NSNumber(value: simplify(value) as Double)
                    do {
                        try context.save()
                    } catch _ {
                    }
                }
                else if sender.keyboardTag == .age {
                    settings!.age = NSNumber(value: value as Double)
                    do {
                        try context.save()
                    } catch _ {
                    }
                }
                else if sender.keyboardTag == .weight {
                    settings!.weight = NSNumber(value: value as Double)
                    do {
                        try context.save()
                    } catch _ {
                    }
                }
            }
        }
        self.tableView.reloadData()
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 0
            }, completion: { _ in
                sender.removeFromSuperview()
        })
    }
    
    func keyboard(_ sender: SUKeyboardView, willChangeValue value: String) -> Bool {
        if sender.keyboardTag == .age {
            let range = value.range(of: ".")
            let age = range != nil ? value.substring(to: range!.lowerBound) : value
            sender.suffix = age2string(Int(age)!).suffix
        }
        return true
    }
    
    // MARK: - NOTIFICATIONS
    func notificationsTitle() -> String {
        return settings!.reminders.boolValue ? "Enabled" : "Disabled"
    }
    
    func doNotificationsEnabled(_ sender: UISwitch?) {
        if sender != nil {
            settings!.reminders = NSNumber(value: !settings!.reminders.boolValue as Bool)
            do {
                try context.save()
            } catch _ {
            }
            let controller = self.presentingViewController as! MainViewController
            controller.doNotifications(nil)
        }
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) {
            cell.detailTextLabel?.text = self.notificationsTitle()
            cell.detailTextLabel?.frame = CGRect(x: cell.textLabel!.frame.minX, y: 0, width: cell.contentView.frame.width - cell.textLabel!.frame.minX, height: cell.frame.height)
        }
        updateNotifications()
    }
    
    // MARK: - MAIL VIEW CONTROLLER
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IN APP PURCHASES
    #if !PREMIUM
    override func productCancelled(_ product: String) {
        super.productCancelled(product)
        let controller = self.presentingViewController as! MainViewController
        removeActivityIndicator(&indicator)
        controller.runInterstitialAd()
    }
    
    override func productPurchased(_ product: String) {
        super.productPurchased(product)
        let controller = self.presentingViewController as! MainViewController
        alert(self, title: "Thank you", message: "Your purchase was successful", tag: 0)
        removeActivityIndicator(&indicator)
        controller.stopInterstitialAd()
        settings!.pro = true
        do {
            try context.save()
        } catch _ {
        }
    }
    
    override func productRestored(_ product: String) {
        super.productRestored(product)
        let controller = self.presentingViewController as! MainViewController
        alert(self, title: "Restore successful", message: "Your purchases have been restored", tag: 0)
        removeActivityIndicator(&indicator)
        controller.stopInterstitialAd()
        settings!.pro = true
        do {
            try context.save()
        } catch _ {
        }
    }
    
    override func productFailed(_ product: String?, error: NSError) {
        super.productFailed(product, error: error)
        let controller = self.presentingViewController as! MainViewController
        removeActivityIndicator(&indicator)
        alert(self, title: "Error", message: error.localizedDescription, tag: 0)
        controller.runInterstitialAdWithDelay()
    }
    
    override func productsNotFound(_ products: AnyObject!) {
        super.productsNotFound(products)
        removeActivityIndicator(&indicator)
        if products is NSArray {
            let product = (products as! NSArray)[0] as! String
            alert(self, title: "Error", message: product + " not found", tag: 0)
        } else {
            super.productsNotFound(products)
        }
    }
    #endif
    
    // MARK: - SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! SecondTableViewController
        if self.type == .collection && self.index != nil {
            let objects = getCollection()
            if objects != nil {
                if objects!.count >= self.index {
                    controller.collectionExistingItem = objects![self.index!]
                    controller.collectionItem = SUCollectionItem(name: objects![self.index!].name, value: objects![self.index!].amount.floatValue)
                }
            }
        } else if self.type == .notifications && self.index != nil {
            let objects = getNotifications()
            if objects != nil {
                if objects!.count >= self.index {
                    controller.reminderExistingItem = objects![self.index!]
                    controller.reminderItem = SUReminderItem(label: objects![self.index!].label, date: objects![self.index!].date)
                }
            }
        }

        controller.type = self.type
        controller.index = self.index
//        controller.transitioningDelegate = viewTransitionDelegate
//        controller.modalPresentationStyle = .Custom
    }
}
