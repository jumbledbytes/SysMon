//
//  SysmonTheme.swift
//  sysmon
//
//  Created by Jeff on 4/28/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        var hexColor = hexString
        if hexColor.characters.count == 7 {
            hexColor = hexColor + "FF";
        }
        
        if hexColor.hasPrefix("#") {
            let start = hexColor.startIndex.advancedBy(1)
            let hexChars = hexColor.substringFromIndex(start)
            
            if hexChars.characters.count >= 6 {
                let scanner = NSScanner(string: hexChars)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexLongLong(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
            
            
        }
        
        return nil
    }
    
    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

class SysmonTheme : Decodable {
    
    class TestColor: Decodable {
        
        let score : Float;
        let colorString : String;
        let color : UIColor;
        
        required init?(json: JSON) {
            self.score = ("score" <~~ json)!;
            self.colorString = ("color" <~~ json)!;
            self.color = UIColor(hexString: self.colorString)!;
        }
        
        init() {
            self.score = -1;
            self.colorString = "#DDDDDD";
            self.color = UIColor(hexString: self.colorString)!;
        }
    }
    
    let themeName : String;
    let testColors : Array<TestColor>;
    static var currentTheme = SysmonTheme();
    
    init() {
        self.themeName = "Undefined"
        self.testColors = Array<TestColor>();
    }
    
    required init?(json: JSON) {
        self.themeName = ("theme_name" <~~ json)!;
        self.testColors = ("test_colors" <~~ json)!;
    }
    
    func getResultColor(result : TestResult) -> UIColor {
        var lowerDelta : Float = 200.0;
        var higherDelta : Float = 200.0;
        var lowerColor = TestColor();
        var higherColor = TestColor();
        var resultColor : UIColor;
        for testColor in testColors {
            let delta = result.testScore - testColor.score
            if(delta > 0) {
                if(delta < lowerDelta) {
                    lowerColor = testColor
                    lowerDelta = delta
                }
            } else if(delta < 0) {
                if(abs(delta) < higherDelta) {
                    higherColor = testColor
                    higherDelta = abs(delta)
                }
            } else {
                higherColor = testColor;
                lowerColor = testColor;
                break;
            }
        }
        
        if(lowerColor.score < 0) {
            lowerColor = higherColor;
        }
        if(higherColor.score < 0) {
            higherColor = lowerColor;
        }
        
        // interpolate color based on distance from lower score and higher score
        let totalColorDistance = higherColor.score - lowerColor.score;
        if(totalColorDistance == 0) {
            resultColor = lowerColor.color
        } else {
            let resultDistance = result.testScore - lowerColor.score;
            let resultScaling = resultDistance / totalColorDistance;
            var lowerHue : CGFloat = 0, lowerSaturation : CGFloat = 0, lowerBrightness : CGFloat = 0, lowerAlpha : CGFloat = 0;
            var higherHue : CGFloat = 0, higherSaturation : CGFloat = 0, higherBrightness : CGFloat = 0, higherAlpha : CGFloat = 0;
            lowerColor.color.getHue(&lowerHue, saturation: &lowerSaturation, brightness: &lowerBrightness, alpha: &lowerAlpha);
            higherColor.color.getHue(&higherHue, saturation: &higherSaturation, brightness: &higherBrightness, alpha: &higherAlpha);
            let newHue = Float(higherHue-lowerHue)*resultScaling + Float(lowerHue);
            let newSaturation = Float(higherSaturation-lowerSaturation)*resultScaling + Float(lowerSaturation);
            let newBrightness = Float(higherBrightness-lowerBrightness)*resultScaling + Float(lowerBrightness);
            let newAlpha = Float(higherAlpha-lowerAlpha)*resultScaling + Float(lowerAlpha);
            resultColor = UIColor(hue: CGFloat(newHue), saturation: CGFloat(newSaturation), brightness: CGFloat(newBrightness), alpha: CGFloat(newAlpha))
        }
        return resultColor
        
    }
}