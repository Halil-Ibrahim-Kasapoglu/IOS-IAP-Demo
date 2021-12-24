//
//  ViewController.swift
//  IAPTask
//
//  Created by Halil Ibrahim Kasapoglu on 16.12.2021.
//

import StoreKit
import UIKit

class ViewController: UIViewController {
    
    let margin : CGFloat = 16
    
    var activityIndicator : UIActivityIndicatorView!
    var contentImageView : UIImageView!
    var informativeLabel : UILabel!
    var buyPremiumButton : UIButton!
    var freeTrialButton : UIButton!
    var freeTrialInformativeLabel : UILabel!
    var statusLabel : UILabel!
    var freeTrialExpiredView : FreeTrialExpiredView!
    
    enum MembershipStatus: String {
        case premium_membership = "premium_membership"
        case in_free_trial = "in_free_trial"
        case free_membership = "free_membership"
    }
        
    
    func getStatus() -> MembershipStatus{
        let membership : String = UserDefaults.standard.value(forKey: "membership") as! String
        print("membership found " + membership)
        return MembershipStatus(rawValue: membership) ?? .free_membership
    }
    func isExpired() -> Bool{
        let hasFreeTrial = !(UserDefaults.standard.value(forKey: "usedFreeTrial") as! Bool)
        if (hasFreeTrial){
            return false
        }
        return Date() > UserDefaults.standard.value(forKey: "freeTrialExpiration") as! Date
    }
    func setStatus(s : MembershipStatus){
        UserDefaults.standard.setValue(s.rawValue, forKey: "membership")
        if (s == .in_free_trial){
            UserDefaults.standard.setValue(true, forKey: "usedFreeTrial")
            let calendar = Calendar.current
            let expirationDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
            print("will expire at", calendar , expirationDate!)
            UserDefaults.standard.setValue(expirationDate, forKey: "freeTrialExpiration")
        }
        fetchContent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        IAPManager.manager.initialize()
        
        loadFreeTrialButton()
        loadContent()
        fetchContent();
    }
    
    func loadActivityIndicator(){
        
        self.view.backgroundColor = .red
        activityIndicator = UIActivityIndicatorView(frame: self.view.bounds);
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator);
        
    }
    
    func loadContent(){
        
        let h : CGFloat = 16
        statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 2 * margin, height: h))
        statusLabel.textAlignment = .center
        statusLabel.center = CGPoint(x: self.view.center.x ,  y: margin + 2 * h)
        self.view.addSubview(statusLabel)
        
        let w : CGFloat = self.view.bounds.width - 2 * margin
        contentImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: w, height:w * 2 / 3))
        contentImageView.center = self.view.center
        self.view.addSubview(contentImageView)
        
        informativeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
        informativeLabel.textAlignment = .center
        informativeLabel.center = CGPoint(x: self.view.center.x ,  y: contentImageView.center.y + w * 2 / 6 + h + margin)
        self.view.addSubview(informativeLabel)
        
        freeTrialExpiredView = FreeTrialExpiredView(frame: CGRect(x: margin, y: margin, width: self.view.bounds.width - 2 * margin, height: self.view.bounds.height - 2 * margin), viewController: self)
        freeTrialExpiredView.backgroundColor = .lightGray
        freeTrialExpiredView.layer.cornerRadius = margin
        freeTrialExpiredView.clipsToBounds = true
        freeTrialExpiredView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        freeTrialExpiredView.layer.shadowRadius = 1.0
        freeTrialExpiredView.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.view.addSubview(freeTrialExpiredView)
    }
    
    func fetchContent(){
        let status = getStatus()
        
        switch status {
        case .in_free_trial:
            statusLabel.text = "In Free Trial"
            break;
        case .free_membership:
            statusLabel.text = "Free Membership"
            break;
        case .premium_membership:
            statusLabel.text = "Premium Membership"
            break;
        }
        
        if (status == .free_membership){
            contentImageView.image = UIImage(named: "solution1_blurred")
            informativeLabel.text = "Pay to see full solution"
        }else {
            contentImageView.image = UIImage(named: "solution1")
            informativeLabel.text = "Full solution";
        }
        
        buyPremiumButton.isHidden = true
        freeTrialButton.isHidden = true
        freeTrialInformativeLabel.isHidden = true
        freeTrialExpiredView.isHidden = true
        
        if (status != .premium_membership){
            buyPremiumButton.isHidden = false
        }
        if (status == .free_membership){
            freeTrialButton.isHidden = false
        }
        if (status == .in_free_trial){
            freeTrialInformativeLabel.isHidden = false
            let expiration = UserDefaults.standard.value(forKey: "freeTrialExpiration") as! Date
            let diffComponents = Calendar.current.dateComponents([.day , .hour], from: Date(), to: expiration)
            freeTrialInformativeLabel.text = "Will expire in \(diffComponents.day ?? 0) days and \(diffComponents.hour ?? 0) hours"
        }
        
        if (status != .premium_membership && isExpired()){
            freeTrialExpiredView.isHidden = false
        }
    }
    
    func loadFreeTrialButton() {
        
        let height : CGFloat = 48
        
        buyPremiumButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 2 * margin , height: height))
        buyPremiumButton.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height - height - margin)
        buyPremiumButton.backgroundColor = .purple
        buyPremiumButton.setTitleColor(.yellow, for: .normal)
        buyPremiumButton.setTitle("Become a Premium Member", for: .normal)
        buyPremiumButton.layer.cornerRadius = margin / 2.0
        buyPremiumButton.addTarget(self, action: #selector(onBuyPremiumClick(sender:)), for: .touchUpInside)
        //buyPremiumButton.addTarget(self, action: #selector(onButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(buyPremiumButton)
        
        freeTrialButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 2 * margin , height: height))
        freeTrialButton.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height - 2 * height - 2 * margin)
        freeTrialButton.backgroundColor = .yellow
        freeTrialButton.setTitleColor(.purple, for: .normal)
        freeTrialButton.setTitle("Start Your Free Trial", for: .normal)
        freeTrialButton.layer.cornerRadius = margin / 2.0
        freeTrialButton.addTarget(self, action: #selector(onFreeTrialClick(sender:)), for: .touchUpInside)
        self.view.addSubview(freeTrialButton)
        
        freeTrialInformativeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 2 * margin , height: height))
        freeTrialInformativeLabel.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height - 2 * height - 2 * margin)
        freeTrialInformativeLabel.backgroundColor = .lightGray
        freeTrialInformativeLabel.textColor = .purple
        freeTrialInformativeLabel.text = "X days remained"
        freeTrialInformativeLabel.clipsToBounds = true
        freeTrialInformativeLabel.textAlignment = .center
        freeTrialInformativeLabel.layer.cornerRadius = margin / 2.0
        self.view.addSubview(freeTrialInformativeLabel)
        
    }
    
    @objc func onFreeTrialClick(sender : UIButton){
        let alertMassage = UIAlertController(title: "Start Free Trial", message: "Do you want to start your 7 Days Free Trial?", preferredStyle: .alert)
        alertMassage.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action) in
            print("approved")
            self.startFreeTrial()
        }))
        alertMassage.addAction(UIAlertAction(title: "No", style: .default, handler: {(action) in print("dismissed")}))
        present(alertMassage, animated: true)
    }
    
    @objc func onBuyPremiumClick(sender : UIButton){
        let alertMassage = UIAlertController(title: "Buy Premium", message: "Do you want to buy Premium Membership?", preferredStyle: .alert)
        alertMassage.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action) in
            print("approved")
            self.buyPremiumMembership()
        }))
        alertMassage.addAction(UIAlertAction(title: "No", style: .default, handler: {(action) in print("dismissed")}))
        present(alertMassage, animated: true)
    }
    
    func buyPremiumMembership(){
        IAPManager.manager.purchase(productParam: IAPManager.manager.products![0]) { () -> (Void) in
            print("i am called")
            self.setStatus(s: .premium_membership)
        }
    }
    
    func startFreeTrial(){
        let hasFreeTrial = !(UserDefaults.standard.value(forKey: "usedFreeTrial") as! Bool)
        print("user has free trial: " , hasFreeTrial)
        if (hasFreeTrial){
            self.setStatus(s: .in_free_trial)
        }
        
    }
    
    
}

