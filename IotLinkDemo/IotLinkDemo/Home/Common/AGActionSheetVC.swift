//
//  AGActionSheetViewController.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/10.
//

import UIKit
import SVProgressHUD

private let kHeaderTitleHeight: CGFloat = 60
private let kItemHeight: CGFloat = 50
private let kCellID = "AGActionSheetCell"

class AGActionSheetCell:UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        return label
    }()
    
    lazy var selectedIndicator:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "country_selected")
        return imgView
    }()

    
    private func createSubviews(){
       
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(54)
        }
        
        contentView.addSubview(selectedIndicator)
        selectedIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-59)
            make.width.height.equalTo(17)
        }
    }
    
}

class AGActionSheetVC: UIViewController {
    
    // 所有条目
    var items:[String] = [String]()
    // 默认选中的索引
    var selectedIndex = 0
    // 标题
    var headerTitle:String? {
        didSet{
            headerView.text = headerTitle
        }
    }
    // 选择结束回调
    var selectedAction: ((_ item:String,_ index:Int)->(Void))?
    
    var alwaysHideIndicator = false
    
    private lazy var headerView:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: kHeaderTitleHeight))
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(AGActionSheetCell.self, forCellReuseIdentifier: kCellID)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
    
    private func setupUI(){
        view.addSubview(tableView)
        let tableHeight = kItemHeight * CGFloat(items.count) + kHeaderTitleHeight + safeAreaBottomSpace()
        tableView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(tableHeight)
        }
    }
    
    static func showTitle(_ title:String?, alwaysHideIndicator: Bool = false, items:[String],selectIndex:Int = 0,selectAction: ((_ item:String,_ index:Int)->(Void))?)  {
        if items.isEmpty {
            debugPrint("items不能是空")
            return
        }
        let vc = AGActionSheetVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.items = items
        vc.alwaysHideIndicator = alwaysHideIndicator
        vc.headerTitle = title
        vc.selectedIndex = selectIndex
        vc.selectedAction = selectAction
        currentViewController().present(vc, animated: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
}


extension AGActionSheetVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kItemHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = self.items[indexPath.row]
        let cell:AGActionSheetCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! AGActionSheetCell
        cell.selectionStyle = .none
        cell.titleLabel.text = title
        if alwaysHideIndicator {
            cell.selectedIndicator.isHidden = true
        }else{
            cell.selectedIndicator.isHidden = selectedIndex != indexPath.row            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let item = items[index]
        dismiss(animated: true)
        self.selectedAction?(item,index)
    }
}
