//
//  ResizeImage.swift
//  MemeMe
//
//  Created by June2020 on 5/18/21.
//

/*  This code is from: https://stackoverflow.com/questions/24709244/how-do-set-a-width-and-height-of-an-image-in-swift
 */

import Foundation
import UIKit

extension UIImage {

    func imageResize (sizeChange:CGSize)-> UIImage{

        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }

}
