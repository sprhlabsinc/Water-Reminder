



import UIKit

#if PREMIUM
    let itunes_url =                "itms-apps://itunes.apple.com/app/apple-store/id1086364619?mt=8"
#else
    let itunes_url =                "itms-apps://itunes.apple.com/app/apple-store/id1086364615?mt=8"
    let google_id =                 "ca-app-pub-5385459629048464/4541196438"
    let default_pid =               "com.suwao.watertracker4.adfree"
    
    let chartboost_appid =          "58d7354df6cd45752d0eb419"
    let chartboost_signaturekey =   "f62c921779f3ea7ab0c3ed45ca51367a68e5a7fb"
    
    //let chartboost_appid =          "58e6e35af6cd457169ffdcc0"
    //let chartboost_signaturekey =   "b7a2d2f89a8ca3636e78e1c67679ba4605114aee"
#endif


let support_email =             "null@email.com"
let facebook_urls =             ["fb://profile/565290953518451", "https://www.facebook.com/suwaoltd"]
let twitter_urls =              ["twitter://user?screen_name=suwaoltd", "https://twitter.com/suwaoltd"]
let ad_interval = 120.0

let colors = [
    UIColor(hex: "#FDFDFD"), // BACKGROUND
    UIColor(hex: "#85C8C7"), // TABLE LABLES
    UIColor(hex: "#237D8F"), // BARS
    UIColor(hex: "#99D1D2"), // BARS BACKGROUND
    UIColor(hex: "#FC6174"), // TOP BUTTON
    UIColor(hex: "#260D05"), // LINES
    UIColor(hex: "#1A6771"), // WEEK DAYS
    UIColor(hex: "#260D05"), // LABELS
    UIColor(hex: "#237D8F"), // VERICAL BAR
    UIColor(hex: "#FC7320")  // DAY HIGHLIGHT
]

let fonts =  [
    UIFont(name: "HelveticaNeue-Light", size: 18.0),
    UIFont(name: "HelveticaNeue-Thin", size: 18.0),
    UIFont(name: "HelveticaNeue-Thin", size: 34.0),
    UIFont(name: "HelveticaNeue-Thin", size: 14.0),
    UIFont(name: "HelveticaNeue", size: 11.0),
    UIFont(name: "HelveticaNeue", size: 14.0),
    UIFont(name: "AvenirNext-Regular", size: 12.0),
    UIFont(name: "AvenirNext-Regular", size: 22.0),
]

let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"] // formatter.shortWeekdaySymbols as [String]

var settings = getSettings()
var redo = [AnyObject]()

let MAX_LIQUID =                [10000.0, 350.0]
let MAX_WEIGHT =                [300.0, 650.0]


