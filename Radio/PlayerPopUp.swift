//
//  PlayerPopUp.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/31/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit

class PlayerPopUp: UIView {
    static let sharedPopUp = PlayerPopUp(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 88, height: 88)));
    var isShow:Bool = false;
    private var playerView:UIView? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        let imageView = UIImageView(frame: frame);
        imageView.image = UIImage(named: "play");
        addSubview(imageView);
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler));
        self.addGestureRecognizer(panGesture);
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler));
        tapGesture.numberOfTapsRequired = 2;
        self.addGestureRecognizer(tapGesture);
        setupPlayerView();
    }
    
    private func setupPlayerView() {
        playerView = UIView.init(frame: CGRect(x: self.frame.maxX - 20, y: self.frame.maxY - 20, width: 100, height: 200));
        playerView?.backgroundColor = .cyan;
        let closeBtn = UIButton(frame: CGRect(origin: CGPoint(x: 30, y: 30), size: CGSize(width: 45, height: 45)));
        playerView?.addSubview(closeBtn);
        closeBtn.addTarget(self, action: #selector(closePlayerview), for: .touchUpInside);
        closeBtn.backgroundColor = .red;
        self.insertSubview(playerView!, belowSubview: self.subviews[0]);
    }
    
    @objc private func closePlayerview() {
        PlayerPopUp.sharedPopUp.hide();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(PlayerPopUp.sharedPopUp);
        PlayerPopUp.sharedPopUp.isShow = true;
    }
    
    func hide() {
        PlayerPopUp.sharedPopUp.removeFromSuperview();
        PlayerPopUp.sharedPopUp.isShow = false;
    }
    
    @objc private func panHandler(_ sender:UIPanGestureRecognizer) {
        let location = sender.location(in: UIApplication.shared.keyWindow);
        self.center = location;
    }
    
    @objc private func tapHandler(_sender:UITapGestureRecognizer) {
        if (PlayerPopUp.sharedPopUp.playerView?.frame.size == CGSize.zero) {
            UIView.animate(withDuration: 1, animations: { 
                PlayerPopUp.sharedPopUp.playerView?.frame.size = CGSize(width: 100, height: 200);
            });
        } else {
            UIView.animate(withDuration: 1, animations: { 
                PlayerPopUp.sharedPopUp.playerView?.frame.size = CGSize.zero;
            })
        }
    }

}
