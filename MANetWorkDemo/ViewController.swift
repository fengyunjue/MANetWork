//
//  ViewController.swift
//  SwiftHTTPManager
//
//  Created by admin on 2018/4/16.
//  Copyright © 2018年 ma. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON
//import MANetWork

class ViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func tagsAction(_ sender: UIButton) {
        ApiRouter.tags.rx_request.showHUD().subscribe(onNext: {[weak self] (json) in
            DispatchQueue.main.async {
                self?.contentTextView.text = "\(json)"
            }
        }).disposed(by: disposeBag)
    }
    @IBAction func commitAction(_ sender: UIButton) {
        ApiRouter.commit(sha: "0f816eedf8d6b7c9a656697e50462145506e48f9").rx_request.showHUD().subscribe(onNext: {[weak self] (json) in
            DispatchQueue.main.async {
                self?.contentTextView.text = "\(json)"
            }
        }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

