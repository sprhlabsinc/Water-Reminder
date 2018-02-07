//
//  MenuView.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 3/31/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import UIKit

class SUMenuView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpace: NSLayoutConstraint!
    var list = NSArray()
    var collection = getCollection()
    
    var controller: UIViewController?
    fileprivate var alt: Bool = false
    
    override func awakeFromNib() {
        if #available(iOS 8.0, *) {
            self.menuTableView.layoutMargins = UIEdgeInsets.zero
        }
        self.menuTableView.isOpaque = false
        self.menuTableView.separatorInset = UIEdgeInsets.zero
        self.menuTableView.separatorColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.menuTableView.backgroundView?.backgroundColor = colors[0]
        self.menuTableView.backgroundColor = colors[0]
    }
    
    func reload(alt: Bool) {
        self.alt = alt
//        if alt {
//            let recent = settings!.recent.floatValue ?? 0
//            options = [["Add Amount", "Add Custom Value"], ["Add Recent", format(NSNumber(float: recent), true, settings!.units.boolValue, false, fraction: 0, spaced: true)], "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
//        }
        if let path = Bundle.main.path(forResource: (alt ? "List" : "Options"), ofType: "plist") {
            let array = NSMutableArray(contentsOfFile: path)
            #if PREMIUM
                if !alt {
                    array!.removeObjectAtIndex(4)
                }
            #endif
            self.list = NSArray(array: array!)
        }
        self.menuTableView.reloadData()
    }
    
    
    
    // MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44 //tableView == settingsTable ? factor(46.0) : 0//factor(32.0)
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 38 //factor(46.0)
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.alt == true {
//            if self.collection != nil {
                return self.collection!.count == 0 ? 2 : 3
//            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.alt {
            return (section == 1 ? ((self.collection?.count)! == 0 ? 2 : collection?.count) : (self.list[section] as AnyObject).count)!
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
        let section = indexPath.section + ((self.collection?.count == 0 && indexPath.section > 0) ? 1 : 0)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: id(indexPath))
        var title: String?
        var detail: String? = nil
        cell.accessoryView = nil
        cell.accessoryType = .none
        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
        
        var array = NSArray()
        if (self.alt == true && ((indexPath.section == 1 && self.collection?.count == 0) || indexPath.section != 1)) {
            array = (self.list[section] as! NSArray)[indexPath.row] as! NSArray
        } else {
            if self.alt {
                array = [String(), String()]
            } else {
                array = self.list[indexPath.row] as! NSArray
            }
        }
        if array.count > 0 {
            title = array[0] as? String
            detail = array[1] as? String
        }
        if self.alt {
            switch (section) {
            case 0:
                switch (indexPath.row) {
                case 1:
                    let recent = settings!.recent.floatValue 
                    detail = format(NSNumber(value: recent as Float), liquid: true, imperial: settings!.units.boolValue, short: false, fraction: 0, spaced: true)
                default:
                    break
                }
            case 1:
                title = self.collection![indexPath.row].name
                detail = format(self.collection![indexPath.row].amount, liquid: true, imperial: settings!.units.boolValue, short: false, fraction: 0, spaced: true)
            case 2:
                let total = indexPath.row == 0 ? getStatistics()?.count : redo.count
                if total == 0 {
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.isEnabled = false
                    cell.detailTextLabel?.isEnabled = false
                }
            default:
                break
            }
        }
        
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
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
        (controller as! MainViewController).tableCellTouched(indexPath)
    }
    
    func isAlt() -> Bool {
        return self.alt
    }
}






