import UIKit

class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            cornerRadius = self.frame.height / 2
            self.layer.cornerRadius = cornerRadius
        }
    }
}
