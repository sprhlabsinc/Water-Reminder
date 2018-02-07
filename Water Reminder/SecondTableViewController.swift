//
//  SecondTableViewController.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 4/6/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class SecondTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, SUKeyboardViewDelegate {
    var type: SUTableType?
    var keyboard: SUKeyboardView?
    var index: Int?
    var list = NSArray()
    var collectionItem: SUCollectionItem?
    var collectionExistingItem: Collection?
    var reminderItem: SUReminderItem?
    var reminderExistingItem: Notifications?
    var isBusy = false
    var textField: UITextField?
    var datePicker: SUDatePicker?
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.5)
        var index: Int?
        if type != nil {
            switch type! {
            case .settings:
                index = 0
            case .calculator:
                index = 2
//            case .Notifications:
//                index = 3
            case .feedback:
                index = 5
            default:
                index = nil
            }
        }

        var title: String?
        if index != nil {
            self.applyButton.isEnabled = false
            self.applyButton.tintColor = UIColor.clear
            if let path = Bundle.main.path(forResource: "Options", ofType: "plist") {
//                let array = NSMutableArray(contentsOfFile: path)
                self.list = (((NSArray(contentsOfFile: path)![index!] as! NSArray)[2] as! NSArray)[self.index!] as! NSArray)[2] as! NSArray
                title = (((NSArray(contentsOfFile: path)![index!] as! NSArray)[2] as! NSArray)[self.index!] as! NSArray)[0] as? String
            }
        } else {
            self.applyButton.isEnabled = true
            self.applyButton.tintColor = self.navigationBar.barTintColor
            if self.type == .collection {
                if self.collectionItem == nil {
                    self.collectionItem = SUCollectionItem()
                }
                title =  self.collectionExistingItem != nil ? "Edit Collection Item" : "New Collection Item"
            } else if self.type == .notifications {
                if self.reminderItem == nil {
                    self.reminderItem = SUReminderItem()
                }
                title =  self.collectionExistingItem != nil ? "Edit Notification" : "New Notification"
            }
        }
        
        let label = titleLabel()
        label.text = title?.capitalized
        label.font = fonts[1]
        self.navigationBar.items![0].titleView = label
        label.sizeToFit()
        
        if #available(iOS 8.0, *) {
            self.tableView.layoutMargins = UIEdgeInsets.zero
        }
        self.tableView.isOpaque = false
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundView?.backgroundColor = colors[0]
        self.tableView.backgroundColor = colors[0]
        self.tableView.tintColor = colors[5]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func doBack(_ sender: AnyObject) {
        self.isBusy = true
        self.view.endEditing(true)
        let controller = self.presentingViewController as! FirstTableViewController
        controller.reload()
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func doApply(_ sender: AnyObject) {
        self.isBusy = true
        if self.type == .collection {
            self.textField?.resignFirstResponder()
            let object = self.collectionExistingItem != nil ? self.collectionExistingItem : (NSEntityDescription.insertNewObject(forEntityName: "Collection", into: context) as! Collection)
            object!.name = self.collectionItem!.name
            object!.amount = NSNumber(value: self.collectionItem!.value as Float)
        } else if self.type == .notifications {
            let object = self.reminderExistingItem != nil ? self.reminderExistingItem : (NSEntityDescription.insertNewObject(forEntityName: "Notifications", into: context) as! Notifications)
            object!.label = self.reminderItem!.label
            object!.date =  self.reminderItem!.date
        }
        do {
            try context.save()
        } catch _ {
        }
        if self.type == .notifications {
            updateNotifications()
        }
        self.doBack(sender)
    }
    
    @IBAction func datePickerChanged(_ sender: SUDatePicker?) {
        if sender != nil {
            if self.reminderItem != nil && sender != nil {
                self.reminderItem!.date = sender!.date
                sender!.label?.text = timeFromDate(sender!.date)
            }
        }
    }
    
    // MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.type == .collection {
            return 2
        } else if self.type == .notifications {
            return 2
        }
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        if self.list.count > 0 {
            if let array = list[indexPath.row] as? NSArray {
                title = array[0] as? String
                detail = array[1] as? String
            }
        }
        
        switch self.type! {
        case .settings:
            switch self.index! {
            case 1:
                // UNITS
                cell.accessoryType = settings?.units.intValue == indexPath.row ? .checkmark : .none
            case 3:
                // SOUND
                cell.accessoryType = settings?.sound.intValue == indexPath.row ? .checkmark : .none
            default:
                break
            }
            case .collection:
                switch indexPath.row {
                case 0:
                    self.textField = makeTextField(tableView, cell: cell, delegate: self)
                    self.textField!.placeholder = "Title"
                    self.textField!.text = self.collectionItem!.name
                    self.textField!.addTarget(self, action: #selector(SecondTableViewController.updateItem(_:)), for: .editingDidEnd)
                    cell.addSubview(self.textField!)
                    if !self.isBusy {
                        delay(0.3, closure: {
                            self.textField!.becomeFirstResponder()
                        })
                    }
                case 1:
                    title = format(NSNumber(value: self.collectionItem!.value as Float), liquid: true, imperial: settings!.units.boolValue, short: false, fraction: 0, spaced: true)
                default:
                    break
                }
                
        case .calculator:
            switch self.index! {
            case 0:
                // GENDER
                cell.accessoryType = settings?.gender.intValue == indexPath.row ? .checkmark : .none
            default:
                break
            }
        case .notifications:
            switch indexPath.row {
            case 0:
                let field = makeTextField(tableView, cell: cell, delegate: self)
                field.placeholder = "Label"
                field.text = reminderItem?.label
                field.addTarget(self, action: #selector(SecondTableViewController.updateItem(_:)), for: .editingDidEnd)
                cell.addSubview(field)
                delay(0.3, closure: {
                    _ = field.becomeFirstResponder()
                })
            case 1:
                for subview in tableView.subviews {
                    if subview is SUDatePicker {
                        subview.removeFromSuperview()
                    }
                }
                title = "Time"
                self.datePicker = SUDatePicker()
                self.datePicker!.datePickerMode = .time
                self.datePicker!.label = cell.detailTextLabel
                self.datePicker!.addTarget(self, action: #selector(SecondTableViewController.datePickerChanged(_:)), for: .valueChanged)
                self.datePicker!.frame = self.datePicker!.bounds.offsetBy(dx: 0, dy: tableView.frame.height - self.datePicker!.bounds.height)
                if self.reminderItem!.date != shift(0) {
                    self.datePicker!.date = self.reminderItem!.date as Date
                }
                self.datePicker!.alpha = 0
                tableView.addSubview(self.datePicker!)
                detail = timeFromDate(self.reminderItem!.date)
                self.reminderItem!.date = Date()
            default:
                break
            }
        default:
            break
        }
        
        if self.list.count > 0 {
            if let array = list[indexPath.row] as? NSArray {
                if array.count > 2 {
                    cell.accessoryView = imageView("DisclosureIndicator", tintColor: UIColor.red)
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
        switch self.type! {
        case .settings:
            switch self.index! {
            case 1:
                if settings != nil {
                    if settings!.units.intValue != indexPath.row {
                        check(tableView, current: indexPath, previous: IndexPath(row: settings!.units.intValue, section: indexPath.section))
                        settings!.units = NSNumber(value: indexPath.row as Int)
                        
                        let statistics = getStatistics()
                        for object in statistics! {
                            object.amount = NSNumber(value: convert(object.amount.doubleValue) as Double)
                        }
                        let collection = getCollection()
                        for object in collection! {
                            object.amount = NSNumber(value: convert(object.amount.doubleValue) as Double)
                        }
                        settings!.goal = NSNumber(value: convert(settings!.goal.doubleValue) as Double)
                        settings!.amount = NSNumber(value: convert(settings!.amount.doubleValue) as Double)
                        settings!.recent = NSNumber(value: convert(settings!.recent.doubleValue) as Double)
                        
                        settings!.weight = NSNumber(value: settings!.units.boolValue ? round(kg2lbs(settings!.weight.doubleValue), step: 0.5) : round(lbs2kg(settings!.weight.doubleValue), step: 0.1) as Double)
                        
                        do {
                            try context.save()
                        } catch _ {
                        }
                    }
                }
            case 3:
                // SOUND
                check(tableView, current: indexPath, previous: IndexPath(row: settings!.sound.intValue, section: indexPath.section))
                settings!.sound = NSNumber(value: indexPath.row as Int)
                do {
                    try context.save()
                } catch _ {
                }
                tableView.reloadData()
                let path = URL(fileURLWithPath: Bundle.main.path(forResource: String(format: "sound_%02i", indexPath.row), ofType: "mp3")!)
                self.audioPlayer = try! AVAudioPlayer(contentsOf: path)
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
                updateNotifications()
            default:
                break
            }
        case .collection:
            switch indexPath.row {
            case 1:
                showKeyboard(self.keyboard, controller: self, delegate: self, title: "Value", suffix: format(nil, liquid: true, imperial: settings!.units.boolValue, short: false), tag: .collectionItem)
                self.isBusy = true
                self.view.endEditing(true)
            default:
                break
            }
        case .calculator:
            if settings!.gender.intValue != indexPath.row {
                check(tableView, current: indexPath, previous: IndexPath(row: settings!.gender.intValue, section: indexPath.section))
                settings!.gender = NSNumber(value: indexPath.row)
                do {
                    try context.save()
                } catch _ {
                }
            }
        case .notifications:
            switch indexPath.row {
            case 1:
                // TIME
                self.isBusy = true
                self.view.endEditing(true)
                UIView.animate(withDuration: 0.45, animations: {
                    self.datePicker!.alpha = 1
                    }, completion: nil)
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK: - TEXT FIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isBusy = false
        if self.type == .notifications {
            UIView.animate(withDuration: 0.15, animations: {
                self.datePicker!.alpha = 0
                }, completion: nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !self.isBusy {
            self.doApply(textField)
        }
    }
    
    func updateItem(_ sender: UITextField?) {
        if self.type == .collection {
            var text = sender?.text ?? SUCollectionItem().name
            let set = CharacterSet.whitespaces
            text = text.trimmingCharacters(in: set)
            if text.isEmpty {
                text = SUCollectionItem().name
                sender?.text = text
            }
            self.collectionItem!.name = text
        } else if self.type == .notifications {
            var text = sender?.text ?? SUReminderItem().label
            let set = CharacterSet.whitespaces
            text = text.trimmingCharacters(in: set)
            if text.isEmpty {
                text = SUReminderItem().label
                sender?.text = text
            }
            self.reminderItem!.label = text
        }
    }
    
    func updateReminder(_ sender: UITextField?) {
        var text = sender?.text ?? SUReminderItem().label
        if text != self.reminderItem?.label {
            let set = CharacterSet.whitespaces
            text = text.trimmingCharacters(in: set)
            if text.isEmpty {
                text = SUReminderItem().label
                sender?.text = text
            }
            self.reminderItem?.label = text
//            settingsTable.reloadData()
        }
    }
    
    // MARK: - KEYBOARD
    func keyboard(_ sender: SUKeyboardView, shouldClose done: Bool) {
        if settings != nil {
            let value = (sender.strip() as NSString).doubleValue
            print("Closing keyboard: \(value)")
            if value > 0 {
//                if sender.keyboardTag == .Goal {
                    let limit = MAX_LIQUID[settings!.units.intValue]
                    if value > limit {
                        messageLessOrEqual(self, value: Int(limit))
                        return
                    }
                            self.collectionItem!.value = Float(value)
//                }
            }
//                else if sender.keyboardTag == .Age {
//                    settings!.age = NSNumber(double: value)
//                    context.save(nil)
//                }
//                else if sender.keyboardTag == .Weight {
//                    settings!.weight = NSNumber(double: value)
//                    context.save(nil)
//                }
//            }
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.3, animations: {
                sender.alpha = 0
                }, completion: { _ in
                    self.isBusy = false
                    self.textField!.becomeFirstResponder()
                    sender.removeFromSuperview()
            })
        }
    }
    
    func keyboard(_ sender: SUKeyboardView, willChangeValue value: String) -> Bool {
        return true
    }
}
