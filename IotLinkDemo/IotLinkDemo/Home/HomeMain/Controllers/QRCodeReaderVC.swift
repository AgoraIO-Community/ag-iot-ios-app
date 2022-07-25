//
//  QRCodeReaderVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/22.
//

import UIKit
import AVFoundation
import SVProgressHUD
//import SwiftyJSON
import Photos
import ZLPhotoBrowser

private let kScanViewY:CGFloat = 150
private let kScanViewWidth:CGFloat = 240

class QRCodeReaderVC: UIViewController {
    
    private var productkey:String?
    private lazy var device:AVCaptureDevice? = {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        return device
    }()
    
    var input:AVCaptureDeviceInput?
    var output:AVCaptureMetadataOutput?
    var preview:AVCaptureVideoPreviewLayer?
    let session:AVCaptureSession = AVCaptureSession()
    
    // 扫码范围的view
    private lazy var scanView:UIView = {
        let view = UIView()
        return view
    }()
    
    // 扫描的线
    private lazy var scanImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "scanLine")
        return imageView
    }()
    
    // 说明
    private lazy var tipsLabel:UILabel = {
        let label = UILabel()
        label.text = "请扫描设备或说明书上的二维码"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    // 非扫描区域蒙版
    private lazy var maskLayer:CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    // 相册按钮
    private lazy var albumButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("相册", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setImage(UIImage(named: "qr_album"), for: .normal)
        button.adjustImageTitlePosition(.top, spacing: 20)
        button.addTarget(self, action: #selector(didClickAlbumButton), for: .touchUpInside)
        return button
    }()
    
    // 手电筒按钮
    private lazy var lightButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("手电筒", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setImage(UIImage(named: "qr_light_off"), for: .normal)
        button.setImage(UIImage(named: "qr_light_on"), for: .selected)
        button.adjustImageTitlePosition(.top, spacing: 20)
        button.addTarget(self, action: #selector(didClickLightButton), for: .touchUpInside)
        return button
    }()
    
    var getScanResult:((String)->(Void))?
    
    deinit {
        preview?.removeFromSuperlayer()
        maskLayer.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupScanQRCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 开始动画
        startAnimate()
        // 开启扫描
        session.startRunning()
    }
    
    // 设置UI
    private func setUpUI(){
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "扫一扫"
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(70)
        }
        
        // 返回按钮
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "qr_back"), for: .normal)
        backButton.addTarget(self, action: #selector(didClickCancel), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalTo(titleLabel)
        }
        
        // 蒙版
        maskLayer.frame = view.layer.bounds
        maskLayer.delegate = self
        view.layer.addSublayer(maskLayer)
        maskLayer.setNeedsDisplay()
        
        // 扫描区域
        view.addSubview(scanView)
        scanView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kScanViewY)
            make.width.height.equalTo(kScanViewWidth)
        }
        
        // 说明
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(scanView.snp.bottom).offset(18)
        }
        
        // 相册
        view.addSubview(albumButton)
        albumButton.snp.makeConstraints { make in
            make.left.equalTo(view.centerX).offset(50)
            make.bottom.equalTo(-120)
        }
        
        // 手电筒开关
        view.addSubview(lightButton)
        lightButton.snp.makeConstraints { make in
            make.right.equalTo(view.centerX).offset(-50)
            make.bottom.equalTo(-120)
        }
    }
    
    // 设置扫描
    private func setupScanQRCode() {
        guard let currentInput = getInput() else { return }
        guard let currentOutput = getOutput() else { return }
        
        //高质量采集
        session.sessionPreset = .high
        
        if session.canAddInput(currentInput) {
            session.addInput(currentInput)
        }
        
        if session.canAddOutput(currentOutput) {
            session.addOutput(currentOutput)
        }
        
        // 设置条码类型为二维码
        currentOutput.metadataObjectTypes = currentOutput.availableMetadataObjectTypes;
        
        // 设置扫描范围
        setOutputInterest()
        
        // 3、实时获取摄像头原始数据显示在屏幕上
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview!.videoGravity = .resizeAspectFill
        preview!.frame = view.layer.bounds
        view.layer.backgroundColor = UIColor.black.cgColor
        view.layer.insertSublayer(preview!, at: 0)
    }
    
    private func getInput()-> AVCaptureDeviceInput?{
        if input != nil {
            return input
        }
        if (device != nil) {
            input = try? AVCaptureDeviceInput(device: device!)
        }
        return input
    }
    
    private func getOutput()->AVCaptureMetadataOutput?{
        if output != nil {
            return output
        }
        output = AVCaptureMetadataOutput()
        output!.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        return output
    }
    
    private func setOutputInterest(){
        let size = view.bounds.size
        let scanViewWidth:CGFloat = kScanViewWidth
        let scanViewHeight:CGFloat = kScanViewWidth
        let scanViewX:CGFloat = (size.width - scanViewWidth) / 2
        let scanViewY:CGFloat = kScanViewY
        let p1 = size.height/size.width
        let f_1920:CGFloat = 1920
        let f_1080:CGFloat = 1080
        let p2 = f_1920 / f_1080 //使用了1080p的图像输出
        guard let currentOutput = getOutput() else { return }
        if (p1 < p2) {
            let fixHeight = self.view.bounds.size.width * f_1920 / f_1080
            let fixPadding = (fixHeight - size.height) / 2
            currentOutput.rectOfInterest = CGRect(x: (scanViewY + fixPadding) / fixHeight, y: scanViewX / size.width, width: scanViewHeight / fixHeight, height: scanViewWidth / size.width);
        } else {
            let fixWidth = self.view.bounds.size.height * f_1080 / f_1920
            let fixPadding = (fixWidth - size.width) / 2
            currentOutput.rectOfInterest = CGRect(x: scanViewY / size.height, y:  (scanViewX + fixPadding) / fixWidth, width: scanViewHeight / size.height, height: scanViewWidth / fixWidth)
        }
    }
    
    // 扫描动画
    private func startAnimate(){
        let X = scanView.bounds.origin.x
        let Y = scanView.bounds.origin.y
        let W:CGFloat = kScanViewWidth
        let H:CGFloat = 7
        scanImageView.frame = CGRect(x: X, y: Y, width: W, height: H)
        scanView.addSubview(scanImageView)
        UIView.animate(withDuration: 2, delay: 0, options: .repeat) {
            self.scanImageView.frame = CGRect(x: X, y: Y + kScanViewWidth, width: W, height: H)
        } completion: { _ in}
    }
    
    // 从图片中识别二维码
    private func stringValueForm(image:UIImage) -> String? {
        let detecor = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        // 获取识别结果
        guard let featrues = detecor?.features(in: CIImage(cgImage: image.cgImage!)) else { return nil }
        if featrues.count == 0 {
            return nil
        }
        
        for featrue in featrues {
            if featrue is CIQRCodeFeature {
                return (featrue as! CIQRCodeFeature).messageString
            }
        }
        return nil
    }
    
    // 弹窗
    
    
// MARK: actions
    // 点击取消
    @objc private func didClickCancel(){
        dismiss(animated: true)
    }
    
    // 点击相册
    @objc private func didClickAlbumButton(){
        showImagePickerVC()
    }
    
    private func showImagePickerVC(){
        let config = ZLPhotoConfiguration.default()
        config.allowSelectVideo = false
        config.allowTakePhoto = false
        config.maxSelectCount = 1
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            guard let image = images.first else {return }
            guard let stringValue = self?.stringValueForm(image: image) else { return }
            self?.parseQRCode(resultStr: stringValue)
        }
        ps.showPhotoLibrary(sender: self)
    }
    
    // 点击手电筒
    @objc private func didClickLightButton(){
        do {
          try device?.lockForConfiguration()
            let isOn = device?.torchMode == .on
            device?.torchMode = isOn ? .off : .on
            device?.unlockForConfiguration()
            self.lightButton.isSelected = !isOn
        }
        catch _ { }
    }
}

extension QRCodeReaderVC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var stringValue:String?
        // 显示遮盖
        SVProgressHUD.show()
        if metadataObjects.count > 0 {
            // 当扫描到数据时，停止扫描
            session.stopRunning()
            // 将扫描的线从移除
            scanImageView.removeFromSuperview()
            if let obj:AVMetadataMachineReadableCodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                stringValue = obj.stringValue
            }
        }
        // 延迟1秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SVProgressHUD.dismiss()
            self.parseQRCode(resultStr: stringValue)
        }
    }
    
    private func parseQRCode(resultStr: String?) {
        guard let result = resultStr else {
            showAlert(withTitle: "没有识别到二维码") {[weak self] _ in
                self?.session.startRunning()
            }
            return
        }
        print(" 识别出的二维码是： \(result)")
        let dict = self.getDictionaryFromJSONString(jsonString: result)
        let key:String? = dict["k"] as? String
        if key != nil {
            dismiss(animated: true) {
                self.getScanResult?(key!)
            }
        }else{
            showAlert(withTitle: "非法的二维码") { [weak self] _ in
                self?.session.startRunning()
            }
        }
    }
    
    func showAlert(withTitle title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "好的", style: .cancel, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension QRCodeReaderVC: CALayerDelegate {

    func draw(_ layer: CALayer, in ctx: CGContext) {
        UIGraphicsBeginImageContextWithOptions(maskLayer.frame.size, false, 1.0)
        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        ctx.setFillColor(color.cgColor)
        ctx.fill(maskLayer.frame)
        let scanFrame = view.convert(scanView.frame, from: scanView.superview)
        ctx.clear(scanFrame)
    }
}

extension QRCodeReaderVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        let stringValue = self.stringValueForm(image: info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        parseQRCode(resultStr: stringValue)
    }
}
