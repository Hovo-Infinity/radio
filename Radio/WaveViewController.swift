//
//  WaveViewController.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 2/16/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import AVFoundation

struct ReadFile {
    static var arrayFloatValues:[Float] = []
    static var points:[CGFloat] = []
    
};

class WaveViewController: UIViewController {
    
    private var fileUrl:URL!
    private var backgroundImageView:UIImageView!
    private var waveView:DrawWaveform!
    
    init(fileUrl : URL!) {
        super.init(nibName: nil, bundle: nil)
        self.fileUrl = fileUrl
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let file = try? AVAudioFile(forReading: fileUrl) else { fatalError("can not create AVAudioFIle") }
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: UInt32(file.length))
        do {
            try file.read(into: buf!)
        } catch {
            print(error.localizedDescription)
        }
        ReadFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buf?.floatChannelData?[0], count: Int(buf!.frameLength)))
        
        self.makeBackground()
    }
    
    func makeBackground() {
        backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "deck")
        view.addSubview(backgroundImageView)
        waveView = DrawWaveform(frame: CGRect(x: 0, y: backgroundImageView.frame.midY - 32, width: backgroundImageView.frame.width, height: 64))
        backgroundImageView.addSubview(waveView)
    }

}
