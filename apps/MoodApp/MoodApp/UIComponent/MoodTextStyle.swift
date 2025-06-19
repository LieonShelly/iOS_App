//
//  MoodTextStyle.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/19.
//

import UIKit
import SwiftUI

enum MoodTextStyle {
    case titleTiny
    case titleExtraSmall
    case titleSmall
    case titleMedium
    case titleLarge
    case titleExtraLarge
    case titleHuge
    
    case bodyExtraSmall
    case bodyExtraSmallBold
    case bodySmall
    case bodySmallBold
    case bodyMedium
    case bodyMediumBold
    case bodyLarge
    
    func fontSize() -> CGFloat {
        switch self {
        case .titleTiny:
            return 16
        case .titleExtraSmall:
            return 18
        case .titleSmall:
            return 20
        case .titleMedium:
            return 24
        case .titleLarge:
            return 28
        case .titleExtraLarge:
            return 36
        case .titleHuge:
            return 48
        case .bodyExtraSmall, .bodyExtraSmallBold:
            return 10
        case .bodySmall, .bodySmallBold:
            return 12
        case .bodyMedium, .bodyMediumBold:
            return 14
        case .bodyLarge:
            return 16
        }
    }
    
    var weight: Font.Weight {
        switch self {
        case .titleTiny:
                .regular
        case .titleExtraSmall:
                .regular
        case .titleSmall:
                .regular

        case .titleMedium:
                .medium
        case .titleLarge:
                .semibold
        case .titleExtraLarge:
                .bold
        case .titleHuge:
                .heavy
        case .bodyExtraSmall:
                .regular
        case .bodyExtraSmallBold:
                .semibold
        case .bodySmall:
                .regular
        case .bodySmallBold:
                .medium
        case .bodyMedium:
                .medium
        case .bodyMediumBold:
                .semibold
        case .bodyLarge:
                .bold
        }
    }
    
    static let spacing: CGFloat = 8
}

extension Font {
    static func moodFont(forTextStyle style: MoodTextStyle) -> Self {
//        let descriptor = UIFontDescriptor.moodFontDescriptor(forTextStyle: style)
//        guard let fontName = descriptor.fontAttributes[.name] as? String else {
//            preconditionFailure("Cannot cast FontName")
//        }
        
//        return Font.custom(fontName, fixedSize: descriptor.pointSize)
        return Font.system(size: style.fontSize(), weight: style.weight, design: .default)
    }
}


extension UIFontDescriptor {

    final class func moodFontDescriptor(forTextStyle style: MoodTextStyle) -> UIFontDescriptor {
        let fontSize = style.fontSize()
        
        let fontName: MoodFont = {
            switch style {
            case .bodyExtraSmall, .bodySmall, .bodyMedium, .bodyLarge:
                return .regular
            case .bodyMediumBold, .bodyExtraSmallBold, .bodySmallBold, .titleTiny, .titleExtraSmall, .titleSmall,
                 .titleMedium, .titleLarge, .titleExtraLarge, .titleHuge:
                return .semiBold
            }
        }()
        let fontDescriptor = UIFontDescriptor(name: fontName.fontName, size: fontSize)
        return fontDescriptor
    }
}


enum MoodFont: String {
   case thin
   case regular
   case bold
   case semiBold
}

extension MoodFont {
   var fontName: String {
       let font = rawValue.split(separator: ".")
       return String(font[0])
   }
   
   var fontExtension: String {
       let font = rawValue.split(separator: ".")
       return String(font[1])
   }
   
   func resourceUrl(bundle: Bundle? = nil) -> URL {
       let fontsBundle = bundle ?? Bundle(for: AppBundle.self)
       
       guard let resourceUrl = fontsBundle.url(forResource: fontName, withExtension: fontExtension) else {
           fatalError("Resource doesn't exist")
       }
       return resourceUrl
   }
}

extension MoodFont: CaseIterable {
   public typealias AllCases = [MoodFont]
   public static var allCases: AllCases {
       return [regular, thin, bold, semiBold]
   }
}
