////
////  CreateQRCodeVC.swift
////  AgoraIoT
////
////  Created by FanPengpeng on 2022/4/25.
////
//
//import UIKit
//
//class CreateQRCodeVC: UIViewController {
//
//    var productKey:String!
//
//    var wifiName:String = ""
//    var password:String = ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//
//    private func setupUI(){
//        self.title = "设备扫码"
//        let cancelBarBtnItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(didClickCancelBarBtnItem))
//        cancelBarBtnItem.tintColor = UIColor(hexRGB: 0x1DD6D6)
//        navigationItem.rightBarButtonItem = cancelBarBtnItem
//
//        view.backgroundColor = .white
//        let qrCodeView = QRCodeView()
//        view.addSubview(qrCodeView)
//        qrCodeView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        qrCodeView.clickCancelButtonAction = {[weak self] in
//            self?.dismiss(animated: true)
//        }
//        qrCodeView.clickCommitButtonAction = {[weak self] in
//            let vc = DeviceConnectingVC()
//            vc.productKey = self?.productKey
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }
//
//        let userId = AgoraIotManager.shared.sdk?.accountMgr.getUserId() ?? ""
//        let qrString = String(format: "{\"s\":\"%@\",\"p\":\"%@\",\"u\":\"%@\",\"k\":\"%@\"}",arguments:[wifiName,password,userId,productKey])
//        print("qrString == \(qrString)")
//        qrCodeView.qrImageView.image = generateQRCode(content: qrString, size: CGSize(width: 200, height: 200))
//    }
//
//
//    // 生成二维码图片
//    func generateQRCode(content: String, size: CGSize) -> UIImage {
//        let stringData = content.data(using: String.Encoding.utf8)
//
//        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
//        qrFilter?.setValue(stringData, forKey: "inputMessage")
//        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
//
//        let colorFilter = CIFilter(name: "CIFalseColor")
//        colorFilter?.setDefaults()
//        colorFilter?.setValuesForKeys(["inputImage" : (qrFilter?.outputImage)!,"inputColor0":CIColor.init(cgColor: UIColor.black.cgColor),"inputColor1":CIColor.init(cgColor: UIColor.white.cgColor)])
//
//        let qrImage = colorFilter?.outputImage
//        let cgImage = CIContext(options: nil).createCGImage(qrImage!, from: (qrImage?.extent)!)
//
//        UIGraphicsBeginImageContext(size)
//        let context = UIGraphicsGetCurrentContext()
//        context!.interpolationQuality = .none
//        context!.scaleBy(x: 1.0, y: -1.0)
//        context?.draw(cgImage!, in: (context?.boundingBoxOfClipPath)!)
//        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return codeImage!
//    }
//
//    @objc private func didClickCancelBarBtnItem(){
//        dismiss(animated: true)
//    }
//
//}
