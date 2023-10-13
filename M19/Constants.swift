//
//  Constants.swift
//  M19
//
//  Created by Александра Угольнова on 02.10.2023.
//
import UIKit

enum Constants {
    enum Colors {
        static var Title: UIColor? {
            UIColor.label
        }
        static var greyDark: UIColor? {
            UIColor.systemGray
        }
        static var greyLight: UIColor? {
            UIColor.systemGray4
        }
        static var BLueLink: UIColor? {
            UIColor.systemBlue
        }
    }
    
    enum Fonts {
        static var ui16Semi: UIFont? {
            UIFont.systemFont(ofSize: 16, weight: .semibold)
        }
        static var ui16Reg: UIFont? {
            UIFont.systemFont(ofSize: 16, weight: .regular)
        }
        static var ui14Regular: UIFont {
            UIFont.systemFont(ofSize: 14, weight: .regular)
        }
        static var ui12Light: UIFont {
            UIFont.systemFont(ofSize: 12, weight: .light)
        }
        static var ui16Bold: UIFont {
            UIFont.systemFont(ofSize: 16, weight: .bold)
        }
        
        static var ui20Reg: UIFont? {
            UIFont.systemFont(ofSize: 20, weight: .regular)
        }
        static var ui20Semi: UIFont? {
            UIFont.systemFont(ofSize: 20, weight: .semibold)
        }
        static var ui16Light: UIFont {
            UIFont.systemFont(ofSize: 16, weight: .light)
        }

    }
    
}
