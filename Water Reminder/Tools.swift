//
//  Tools.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 3/23/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import UIKit
import CoreGraphics
import CoreData

let app_shortname = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
let app_version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
let app_executable = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as! String
let app_identifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
let app_fullname = [app_shortname, app_version].joined(separator: ", ")

var context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!

enum SUDeviceType {
    case classic, phone5, phone6, phone6Plus, pad
}

enum SUTableType {
    case settings, collection, calculator, notifications, history, feedback, upgrades
}

enum SUKeyboardViewTag {
    case add, goal, weight, age, `default`, collectionItem
}

class SUDatePicker: UIDatePicker {
    var label: UILabel?
}

struct SUCollectionItem {
    var name: String
    var value: Float
    init() {
        self.name = "Untitled"
        self.value = 0.0
    }
    init(name: String, value: Float) {
        self.name = name
        self.value = value
    }
}

struct SUReminderItem {
    var label: String
    var date: Date
    init() {
        self.label = "Keep calm and drink water"
        self.date = Date()
    }
    init(label: String, date: Date) {
        self.label = label
        self.date = date
    }
}

func  CGRectFromCGSize(_ size: CGSize) -> CGRect {
    return CGRect(x: 0, y: 0, width: size.width, height: size.height)
}

func rgba(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha/255.0)
}

func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return rgba(red, green: green, blue: blue, alpha: 255.0)
}

func id(_ indexPath: IndexPath) -> String {
    return String(format: "ID%i-%i", indexPath.section, indexPath.row)
}

func device() -> String {
    var size: Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String(cString: machine)
}

func open(_ arr: [String]) {
    for str in arr {
        let url = URL(string: str)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
            break
        }
    }
}

func alert(_ delegate: UIAlertViewDelegate, title: String, message: String, tag: Int) {
    let alert = UIAlertView(title: title, message:message, delegate:delegate, cancelButtonTitle:"OK")
    alert.tag = tag
    alert.show()
}

func shadow(_ view: UIView, offset: CGSize) {
    let layer = view.layer as CALayer
    layer.shadowOffset = offset
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowRadius = 1.0
    layer.shadowOpacity = 0.75
    layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
}

func fontList() {
    for family in UIFont.familyNames {
        print("Family Name: \(family)")
        for name in UIFont.fontNames(forFamilyName: family ) {
            print("-Font Name: \(name)")
        }
    }
}

func textSize(_ text: String, font: UIFont) -> CGSize {
    let attributes = [NSFontAttributeName:font]
    return text.size(attributes: attributes)
}

func shift(_ offset: Double, date: Date = Date()) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let components = (calendar as NSCalendar).components([.day, .month, .year], from:date)
    return Date(timeInterval: 86400.0 * offset, since: calendar.date(from: components)!)
}

func weekday(_ date: Date?) -> Int {
    let source = date ?? Date()
    let calendar = Calendar(identifier: .gregorian)
    let components = (calendar as NSCalendar).components(.weekday, from: source)
    return components.weekday!
}

func format(_ value: NSNumber?, liquid: Bool, imperial: Bool, short: Bool, fraction: Int = 0, spaced: Bool = false) -> String {
    var string = ""
    let number = (value != nil && !imperial && short) ? NSNumber(value: value!.floatValue / 1000 as Float) : value
    if number != nil {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = fraction
        string = formatter.string(from: number!)!
    }
    let source = spaced ? "%@ %@" : "%@%@"
    if liquid {
        return String(format: source, string, imperial ? "oz" : short ? "L" : "ml")
    }
    return String(format: source, string, imperial ? "lbs" : "kg")
}

func age2string(_ age: Int) -> (full: String, suffix: String) {
    let last = age % 10
    let suffix = String(format: " year%@", last == 1 ? "" : "s")
    return (String(format: "%i%@", age, suffix), suffix)
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func kg2lbs(_ value: Double) -> Double {
    return value * 2.20462
}

func lbs2kg(_ value: Double) -> Double {
    return value * 0.453592
}

func ml2oz(_ value: Double) -> Double  {
    return value * 0.033814
}

func oz2ml(_ value: Double) -> Double  {
    return value * 29.5735
}

func round(_ value: Double, step: Double) -> Double {
    if (value >= 0) {
        return step * floor((value / step) + 0.5)
    } else {
        return step * ceil((value / step) + 0.5)
    }
}

func check(_ tableView: UITableView, current: IndexPath, previous: IndexPath) {
    tableView.cellForRow(at: previous)?.accessoryType = .none
    tableView.cellForRow(at: current)?.accessoryType = .checkmark
}

func imageView(_ imageNamed: NSString, tintColor: UIColor) -> UIImageView {
    let image = UIImage(named: imageNamed as String)!.withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: image)
    if imageView.responds(to: #selector(setter: UIView.tintColor)) {
        imageView.tintColor = tintColor
    }
    return imageView;
}

//func gaussianBlur(source: UIImage, radius: CGFloat) -> UIImage {
//    UIGraphicsBeginImageContextWithOptions(source.size, false, UIScreen.mainScreen().scale)
//    let ciimage: CIImage = CIImage(image: source)
//    let filter = CIFilter(name: "CIGaussianBlur")
//    filter.setValue(ciimage, forKey: kCIInputImageKey)
//    filter.setValue(radius, forKey: kCIInputRadiusKey)
//    let outputImage = filter.outputImage.imageByCroppingToRect(CGRectFromCGSize(source.size))
//    UIGraphicsEndImageContext()
//    return UIImage(CIImage: outputImage)!
//}

//func blurredBackground(view: UIView) -> UIImageView {
//    UIGraphicsBeginImageContext(view.frame.size);
//    view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates:false)
//    let snapshotImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
//    let image = gaussianBlur(snapshotImage, 5.0)
//    return UIImageView(image: image)
//}

func circle(_ color: UIColor!, size: CGSize, width: CGFloat) -> UIImage  {
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    let path = UIBezierPath(ovalIn: CGRect(x: width / 2, y: width / 2, width: size.width - width, height: size.height - width))
    color.setStroke()
    path.lineWidth = width
    path.stroke()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

func filledCircle(_ fillColor: UIColor!, borderColor: UIColor!, size: CGSize, width: CGFloat) -> UIImage  {
    
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    var path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    fillColor.setFill()
    path.fill()
    
    path = UIBezierPath(ovalIn: CGRect(x: width, y: width, width: size.width - width * 2, height: size.height - width * 2))
    borderColor.setFill()
    path.fill()
    
    path = UIBezierPath(ovalIn: CGRect(x: width * 2, y: width * 2, width: size.width - width * 4, height: size.height - width * 4))
    fillColor.setFill()
    path.fill()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

func dispatch_after_delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension UILabel {
    func decorate(_ range: NSRange, font: UIFont, color: UIColor?) {
        if range.length == 0 || !self.responds(to: #selector(setter: UITextField.attributedText)) {
            return
        }
        let text = NSMutableAttributedString(attributedString: self.attributedText!)
        var dictionary = [NSFontAttributeName: font] as [String: AnyObject]
        if color != nil {
            dictionary[NSForegroundColorAttributeName] = color!
        }
        text.setAttributes(dictionary, range: range)
        self.attributedText = text
    }
}

extension UIColor {
    convenience init(hex: String) {
        let string: NSString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let scanner = Scanner(string: string as String)
        
        if (string.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Int(color >> 16) & mask) / 255.0
        let g = CGFloat(Int(color >> 8) & mask) / 255.0
        let b = CGFloat(Int(color) & mask) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    func hex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
    }
    
    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
    }
}

extension UIImage {
    func tintColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -self.size.height)
        context?.setBlendMode(CGBlendMode.multiply)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UITabBar {
    func itemIndex(_ item: UITabBarItem?) -> Int {
        if item != nil {
            if let index = self.items!.index(of: item!) {
                return index
            }
        }
        return 0
    }
}


class SUStoryboardSegue: UIStoryboardSegue {
    
    override func perform() {
        let firstView = self.source.view as UIView!
        let secondView = self.destination.view as UIView!
        
        let screen = UIScreen.main.bounds.size

        secondView?.frame = CGRect(x: 0, y: screen.height, width: screen.width, height: screen.height)
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondView!, aboveSubview: firstView!)
        
        // Animate the transition.
        UIView.animate(withDuration: 0.4, animations: { _ in
            firstView?.frame = (firstView?.frame.offsetBy(dx: 0.0, dy: -screen.height))!
            secondView?.frame = (secondView?.frame.offsetBy(dx: 0.0, dy: -screen.height))!
            }, completion: { _ in
                self.source.present(self.destination ,
                    animated: false,
                    completion: nil)
        }) 
    }
}

class SUTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimator = SUPresentationAnimator()
        return presentationAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissalAnimator = SUDismissalAnimator()
        return dismissalAnimator
    }
}

class SUPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning  {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        let animationDuration = self .transitionDuration(using: transitionContext)
        
        // take a snapshot of the detail ViewController so we can do whatever with it (cause it's only a view), and don't have to care about breaking constraints
        let snapshotView = toViewController.view.resizableSnapshotView(from: toViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        snapshotView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        snapshotView?.center = fromViewController.view.center
        containerView.addSubview(snapshotView!)
        
        // hide the detail view until the snapshot is being animated
        toViewController.view.alpha = 0.0
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: [],
            animations: { _ in
                snapshotView?.transform = CGAffineTransform.identity
            }, completion: { (finished) -> Void in
                snapshotView?.removeFromSuperview()
                toViewController.view.alpha = 1.0
                transitionContext.completeTransition(finished)
        })
    }
}

class SUDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        let animationDuration = self .transitionDuration(using: transitionContext)
        
        let snapshotView = fromViewController.view.resizableSnapshotView(from: fromViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        snapshotView?.center = toViewController.view.center
        containerView.addSubview(snapshotView!)
        
        fromViewController.view.alpha = 0.0
        
        let toViewControllerSnapshotView = toViewController.view.resizableSnapshotView(from: toViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        containerView.insertSubview(toViewControllerSnapshotView!, belowSubview: snapshotView!)
        
//        UIView.animateWithDuration(animationDuration, animations: { _ in
            UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: [],
            animations: { _ in
            snapshotView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            snapshotView?.alpha = 0.0
            }) { (finished) -> Void in
                toViewControllerSnapshotView?.removeFromSuperview()
                snapshotView?.removeFromSuperview()
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}

func convert(_ value: Double, liquid: Bool = true) -> Double {
    if settings == nil {
        return 0
    }
    if liquid {
        return settings!.units.boolValue ? round(ml2oz(value), step: 1.0) : round(oz2ml(value), step: 50.0)
    } else {
        return settings!.units.boolValue ? round(kg2lbs(settings!.weight.doubleValue), step: 0.5) : round(lbs2kg(settings!.weight.doubleValue), step: 0.1)
    }
}

func simplify(_ value: Double, liquid: Bool = true) -> Double {
    if liquid {
        return settings!.units.boolValue ? round(value, step: 1.0) : round(value, step: 50.0)
    } else {
        return settings!.units.boolValue ? round(value, step: 0.5) : round(value, step: 0.1)
    }
}

func timeFromDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

func calculate() -> Double {
    if settings != nil {
        let weight = settings!.units.boolValue ? lbs2kg(settings!.weight.doubleValue) : settings!.weight.doubleValue
//        let activity = (200 + 100 * settings!.gender.integerValue) * settings!.activity.integerValue / 60
        let gender = settings!.gender.doubleValue == 0 ? 1.0 : 0.0
        var liquid = (weight - 20.0) * 15.0 + 1500.0 + weight * gender * 6.0
        if settings!.age.floatValue > 54 && settings!.age.floatValue < 74 {
            liquid -= 4 * weight
        } else if settings!.age.floatValue > 74 {
            liquid = liquid - 8 * weight
        }
        return settings!.units.boolValue ? convert(liquid) : simplify(liquid)
    }
    return 0
}

func showKeyboard(_ keyboard: SUKeyboardView?, controller: UIViewController, delegate: SUKeyboardViewDelegate, title: String, suffix: String, tag: SUKeyboardViewTag) {
    var keyboard = keyboard
    keyboard = SUKeyboardView(frame: UIScreen.main.bounds, delegate: delegate, title: title)
    keyboard!.keyboardTag = tag
    keyboard!.suffix = suffix
    keyboard!.update()
    
    keyboard!.alpha = 0
    controller.view.addSubview(keyboard!)
    UIView.animate(withDuration: 0.3, animations: {
        keyboard!.alpha = 1
        }, completion: nil)
}

func messageLessOrEqual(_ delegate: UIAlertViewDelegate, value: Int) {
    alert(delegate, title: "Wrong Value", message: String(format: "Value must be less than or equal to %i", value), tag: 0)
}

func messageGreaterOrEqual(_ delegate: UIAlertViewDelegate, value: Int) {
    alert(delegate, title: "Wrong Value", message: String(format: "Value must be greater than or equal to %i", value), tag: 0)
}

func makeTextField(_ tableView: UITableView, cell: UITableViewCell, delegate: UITextFieldDelegate) -> UITextField {
    let field = UITextField(frame: CGRect(x: 14.0, y: 8.0, width: tableView.frame.width - 28.0, height: cell.frame.height - 16.0))
    field.font = fonts[1]
    field.clearButtonMode = .always
    field.returnKeyType = .done
    field.delegate = delegate
    cell.addSubview(field)
    cell.selectionStyle = .none
    return field
}

func updateNotifications() {
    UIApplication.shared.cancelAllLocalNotifications()
    let objects = getNotifications()
    if objects == nil || !settings!.reminders.boolValue {
        return
    }
    for object in objects!.enumerated() {
        var components = (Calendar.current as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.NSMinuteCalendarUnit], from: object.element.date as Date)
        components.second = 0
        let date = (Calendar.current as NSCalendar).date(byAdding: components, to: shift(0), options: NSCalendar.Options())
        let notification = UILocalNotification()
        notification.timeZone = TimeZone.current
        notification.hasAction = true
        notification.fireDate = date
        notification.alertBody = object.element.label
        notification.repeatInterval = .NSDayCalendarUnit
        notification.soundName = String(format: "sound_%02i.mp3", settings!.sound.intValue)
        notification.applicationIconBadgeNumber = 1
        UIApplication.shared.scheduleLocalNotification(notification)
        print("Fire date: \(date)")
    }
}

func topMostController(_ viewController: UIViewController) -> UIViewController? {
    var controller = UIApplication.shared.keyWindow!.rootViewController
    while controller?.presentedViewController != nil {
        controller = controller?.presentedViewController
    }
    return controller
}

func showActivityIndicator(_ indicator: inout UIActivityIndicatorView?, view: UIView) {
    if indicator == nil {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let size = CGSize(width: 48.0, height: 48.0)
        indicator = UIActivityIndicatorView(activityIndicatorStyle:.white)
        indicator?.frame = CGRect(x: view.frame.midX - size.width / 2.0, y: view.frame.midY - size.height / 2.0, width: size.width, height: size.height)
        indicator?.hidesWhenStopped = true
        indicator?.alpha = 0.6
        indicator?.backgroundColor = UIColor.black
        indicator?.layer.cornerRadius = 4.0
        view.addSubview(indicator!)
        indicator?.startAnimating()
    }
}

func removeActivityIndicator(_ indicator: inout UIActivityIndicatorView?) {
    if indicator != nil {
        UIApplication.shared.endIgnoringInteractionEvents()
        indicator?.removeFromSuperview()
        indicator = nil
    }
}

//MARK: - LOCAL
func titleLabel() -> UILabel {
    let titleLabel = UILabel(frame: CGRect.zero)
    titleLabel.textColor = colors[0]
    titleLabel.font = fonts[1]
    titleLabel.sizeToFit()
    return titleLabel
}

func titleLabelWithItem(_ item: UINavigationItem) {
    let label = titleLabel()
    label.text = "MYCUP"
    label.decorate(NSRange(location: 2, length: 3), font: fonts[0]!, color: colors[0])
    item.titleView = label
    label.sizeToFit()
}

// MARK: - CORE DATA
func getSettings() -> Settings? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
    request.returnsObjectsAsFaults = false
    do {
        let objects = try context.fetch(request) as! [Settings]
        var object = objects.last
        if object == nil {
            object = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: context) as? Settings
            #if PREMIUM
                object!.pro = true
                #else
                object!.pro = false
            #endif
            object!.gender = 0
            object!.goal = 2500
            object!.weight = 75.00
            object!.age = 30
            object!.sound = 0
            object!.units = 0
            object!.recent = 0
            object!.name = "Default"
            object!.reminders = false
            object!.amount = 250
            object!.stamp = shift(0)
        }
        return object!
    } catch {
        print("Could not fetch: \(error)")
        return nil
    }
}

func getStatistics() -> [Statistics]? {
//    var result = [Statistics]()
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Statistics")
    request.returnsObjectsAsFaults = false
    
    do {
        let objects = try context.fetch(request) as! [Statistics]
//        for object in objects {
//            result.append(object as Statistics)
//        }
        return objects//result
    } catch {
        print("Could not fetch: \(error)")
        return nil
    }
}

func getCollection() -> [Collection]? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Collection")
    do {
        let objects = try context.fetch(request) as? [Collection]
        var result = [Collection]()
        for object in objects! {
            result.append(object as Collection)
        }
        return result
    } catch {
        print("Could not fetch: \(error)")
        return nil
    }
}

func getNotifications() -> [Notifications]? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
    do {
        let objects = try context.fetch(request) as? [Notifications]
        var result = [Notifications]()
        for object in objects! {
            result.append(object as Notifications)
        }
        return result
    } catch {
        print("Could not fetch: \(error)")
        return nil
    }
}

func deleteEntity( _ name: String) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
    do {
        let objects = try context.fetch(request) as! [NSManagedObject]
        for object in objects {
            context.delete(object)
        }
        try context.save()
    } catch {
        print("Could not save: \(error)")
    }
}

func lastActivityWithStartDate(_ date: Date) -> String {
    let range = (Calendar(identifier:Calendar.Identifier.gregorian) as NSCalendar).range(of: .day, in: .month, for: Date())
    let second: Double = 1
    let minute: Double = 60 * second
    let hour: Double = 60 * minute
    let day: Double = 24 * hour
    let month: Double = Double(range.length) * day
    
    let delta = Date().timeIntervalSince(date)
    
    if (delta < 1 * minute) {
        return delta == 1 ? "one second ago" : String(format: "%d seconds ago", Int(delta))
    } else if (delta < 2 * minute) {
        return "a minute ago"
    } else if (delta < hour) {
        let minutes = floor(delta / minute)
        return String(format: "%d minutes ago", Int(minutes))
    } else if (delta < 2 * hour) {
        return "an hour ago"
    } else if (delta < day) {
        let hours = floor(delta / hour)
        return String(format: "%d hours ago", Int(hours))
    } else if (delta < 2 * day) {
        return "yesterday"
    } else if (delta < month) {
        let days = floor(delta / day)
        return String(format: "%d days ago", Int(days))
    } else if (delta < 12 * month) {
        let months = floor(delta / month)
        return months <= 1 ? "one month ago" : String(format: "%d months ago", Int(months))
    }
    else {
        let years = floor(delta / month / 12.0)
        return years <= 1 ? "one year ago" : String(format: "%d years ago", Int(years))
    }
}





