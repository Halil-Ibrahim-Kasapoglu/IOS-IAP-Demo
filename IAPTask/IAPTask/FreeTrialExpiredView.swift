//
//  FreeTrialExpiredView.swift
//  IAPTask
//
//  Created by Halil Ibrahim Kasapoglu on 17.12.2021.
//

import UIKit

class FreeTrialExpiredView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var parentVC : ViewController!
    
    init(frame: CGRect, viewController : ViewController ) {
        self.parentVC = viewController
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func draw(_ rect: CGRect) {
        
        let height : CGFloat = 48
        let margin : CGFloat = 16
        
        let statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width - 2 * margin, height: height))
        statusLabel.textAlignment = .center
        statusLabel.text = "Your Free Trial has expired!"
        statusLabel.center = CGPoint(x: self.bounds.width / 2 ,  y: margin + 2 * height)
        self.addSubview(statusLabel)
        
        let buyPremiumButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width - 2 * margin , height: height))
        buyPremiumButton.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height/2)
        buyPremiumButton.backgroundColor = .purple
        buyPremiumButton.setTitleColor(.yellow, for: .normal)
        buyPremiumButton.setTitle("Become a Premium Member", for: .normal)
        buyPremiumButton.layer.cornerRadius = margin / 2.0
        buyPremiumButton.addTarget(self, action: #selector(onBuyPremiumClick(sender:)), for: .touchUpInside)
        self.addSubview(buyPremiumButton)
    }
    
    @objc func onBuyPremiumClick(sender : UIButton){
        let alertMassage = UIAlertController(title: "Buy Premium", message: "Do you want to buy Premium Membership?", preferredStyle: .alert)
        alertMassage.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action) in
            print("approved")
            self.buyPremiumMembership()
        }))
        alertMassage.addAction(UIAlertAction(title: "No", style: .default, handler: {(action) in print("dismissed")}))
        parentVC.present(alertMassage, animated: true)
    }
    
    func buyPremiumMembership(){
        IAPManager.manager.purchase(productParam: IAPManager.manager.products![0]) { () -> (Void) in
            print("i am called")
            self.parentVC.setStatus(s: .premium_membership)
            self.removeFromSuperview();

        }
    }
}
