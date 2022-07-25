//
//  DownloadProgressVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/30.
//

import UIKit

private let kHeaderTitleHeight: CGFloat = 60
private let kItemHeight: CGFloat = 50
private let kCellID = "DownloadProgressCell"

class DownloadProgressCell:UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var progress:UIProgressView = {
        let progress = UIProgressView()
        return progress
    }()
    
    private lazy var cancelButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitle("已取消", for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor(hexRGB: 0x1DD6D6), for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x000000, alpha: 0.3), for: .disabled)
        button.addTarget(self, action: #selector(didClickCancelButton), for: .touchUpInside)
        return button
    }()
    
    var downloadInfo:DownloadInfo? {
        didSet{
            let currProgress = downloadInfo?.progress ?? 0.0
            progress.progress = currProgress
            if currProgress >= 1.0 {
                cancelButton.setTitle("已完成", for: .disabled)
                cancelButton.isEnabled = false
            }else{
                cancelButton.setTitle("已取消", for: .disabled)
                cancelButton.isEnabled = downloadInfo?.isCanceled == false
            }
        }
    }
    
    var clickCancelButtonAction:(()->(Void))?

    private func createSubviews(){
       
        contentView.addSubview(progress)
        progress.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(30)
            make.right.equalTo(-100)
        }
        
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-30)
            make.width.equalTo(60)
        }
    }
    
    @objc private func didClickCancelButton(){
        clickCancelButtonAction?()
    }

    
}

class DownloadProgressVC: UIViewController {
    
    // 所有条目
    var items:[DownloadInfo] = [DownloadInfo]()
    
    deinit {
        timer?.invalidate()
    }
    
    private lazy var headerView:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: kHeaderTitleHeight))
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        label.textAlignment = .center
        label.text = "下载进度"
        return label
    }()
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(DownloadProgressCell.self, forCellReuseIdentifier: kCellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        let cornerRadius = 30
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width:cornerRadius,height:cornerRadius)).cgPath
        tableView.layer.mask = maskLayer
        return tableView
    }()

    var timer :Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        setupUI()
        addTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
    
    private func addTimer(){
        timer = Timer(timeInterval: 0.5, target: self , selector: #selector(handleTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .default)
    }
    
    private func setupUI(){
        view.addSubview(tableView)
        let tableHeight = kItemHeight * CGFloat(items.count) + kHeaderTitleHeight + safeAreaBottomSpace()
        tableView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(tableHeight)
        }
    }
    
    @objc private func handleTimer(){
        self.tableView.reloadData()
    }
    
    static func show()  {
        let vc = DownloadProgressVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.items = DoorbellDownlaodManager.shared.downloadInfoArray
        currentViewController().present(vc, animated: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
}


extension DownloadProgressVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kItemHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = self.items[indexPath.row]
        let cell:DownloadProgressCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! DownloadProgressCell
        
        cell.selectionStyle = .none
        cell.downloadInfo = info
        cell.clickCancelButtonAction = {[weak self] in
            DoorbellDownlaodManager.shared.cancelDownload(url: info.url)
            self?.tableView.reloadData()
        }
        return cell
    }
    
}
