//
//  CountrySelectVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/22.
//

import UIKit

fileprivate let TDInvoiceApplyCellID = "TDInvoiceApplyCellID"

class CountrySelectVC: AGBaseVC {
    
    typealias CountrySelectVCBlock = (_ type:String,_ name:String) -> ()
    var countryVCBlock:CountrySelectVCBlock?
    
    //MARK: - 国家数据
    fileprivate var dataArr = [CountryModel]()
    
    fileprivate var currentSelectCode = ""
    fileprivate var currentModel = CountryModel()
    
    var countryArray : [CountryModel]?{
        didSet{
            
            guard let countryArray = countryArray else { return }
    
            for i in 0..<2 {
                let tempModel = CountryModel()
                if i == 0 {
                    tempModel.countryName = "中国"
                    tempModel.countryCode = "86"
                }else if i == 1{
                    tempModel.countryName = "美国"
                    tempModel.countryCode = "1"
                }
                
                dataArr.append(tempModel)
               
            }
            invoceTabV.reloadData()
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentSelectCode = TDUserInforManager.shared.currentCountryCode
        currentModel = TDUserInforManager.shared.curCountryModel ?? CountryModel()
        setNavigation()
        setupUI()
    }
    
    func setNavigation() {
        
        navigationItem.leftBarButtonItem=UIBarButtonItem(image: UIImage(named: "navBack_new")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBtnDidClick))
    }
    
    //点击左上角返回按钮
    @objc func leftBtnDidClick(){
        
        countryVCBlock!(currentModel.countryCode,currentModel.countryName)
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupUI(){
        
        self.title = "选择国家/地区"
        
        view.backgroundColor = UIColor.init(hexString: "#FFFFFF")
        
        view.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(22.VS)
            make.left.equalTo(30.S)
            make.right.equalTo(-30.S)
        }
        
        view.addSubview(bgV)
        bgV.snp.makeConstraints { (make) in
            make.top.equalTo(55.VS)
            make.bottom.left.right.equalToSuperview()
        }
        
        bgV.addSubview(invoceTabV)
        invoceTabV.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    fileprivate lazy var bgV : UIView = {
        let bgV = UIView.init()
        bgV.backgroundColor = UIColor.init(hexString: "#FFFFFF")
        bgV.layer.cornerRadius = 5.S
        bgV.layer.masksToBounds = true
        return bgV
    }()
    
    fileprivate lazy var titleLbl : UILabel = {
        let label = UILabel.init()
        label.text = "请注意，如果选择的国家/地区不正确，可能影响正常使用"
        label.textColor = UIColor.init(hexString: "#000000")
        label.alpha = 0.5
        label.font = FontPFRegularSize(12)
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    fileprivate lazy var invoceTabV: UITableView = {

        let tempTabV = UITableView.init(frame: CGRect.zero , style: .grouped)

        tempTabV.separatorStyle = .none

        tempTabV.delegate = self

        tempTabV.dataSource = self

        tempTabV.backgroundColor = UIColor.clear

        tempTabV.register(CountrySelectViewCell.self, forCellReuseIdentifier: TDInvoiceApplyCellID)

        tempTabV.showsVerticalScrollIndicator = true
        
        tempTabV.estimatedRowHeight = 46

        tempTabV.estimatedSectionFooterHeight = 10

        tempTabV.estimatedSectionHeaderHeight =  10

        if #available(iOS 11.0, *) {

            tempTabV.contentInsetAdjustmentBehavior = .never

        } else {

            automaticallyAdjustsScrollViewInsets=false
        }

        return tempTabV
    }()
    
}

//MARK: - 表格代理事件
extension CountrySelectVC:UITableViewDelegate,UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {

         return 1
    }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

         return dataArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let model = dataArr[indexPath.row]
        let cell: CountrySelectViewCell = tableView.dequeueReusableCell(withIdentifier: TDInvoiceApplyCellID, for: indexPath) as! CountrySelectViewCell
        cell.selectionStyle = .none
        cell.model = model
        cell.index = indexPath

        cell.isSelected = model.countryCode == currentSelectCode
        cell.check.isHidden = model.countryCode != currentSelectCode
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 46.VS
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{

        return 0.001.S
    }


    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{

        return 0.001.S
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){

        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataArr[indexPath.row]
        currentSelectCode = model.countryCode
        currentModel = model
        TDUserInforManager.shared.curCountryModel = model
        TDUserInforManager.shared.currentCountryCode = model.countryCode
        
        let cell = tableView.cellForRow(at: indexPath) as! CountrySelectViewCell
        cell.check.isHidden = cell.isSelected
        
        tableView.reloadData()
        
        countryVCBlock!(model.countryCode,model.countryName)
        self.navigationController?.popViewController(animated: true)

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{

        return UIView()
    }


    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{

        return UIView()
    }
}
