//
//  CountrySelectViewCell.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/24.
//

import UIKit

class CountrySelectViewCell: UITableViewCell {
    
    var index : IndexPath?{
        didSet{
        }
    }
    
    var model : CountryModel?{
        didSet{
            guard let model = model else { return }
            
            titleLabel.text = model.countryName
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = BGColor
        addsubViews()
    }
    
    //MARK: - addsubViews
    private func addsubViews() {

        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        bgView.addSubview(check)
        check.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-40.S)
            make.centerY.equalToSuperview()
            make.width.equalTo(17.S)
            make.height.equalTo(17.S)
        }
        
        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(35.S)
            make.width.equalTo(160.S)
            make.height.equalTo(22.S)
        }
        
        bgView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalTo(17.S)
            make.right.equalTo(-17.S)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
  
        check.isHidden = true
    }
    
    lazy var bgView: UIView = {
        let vew = UIView()
        vew.backgroundColor = UIColor.init(hexString: "#FFFFFF")
        return vew
    }()
    
    lazy var check : UIImageView = {
        let check = UIImageView()
        check.image = UIImage.init(named: "country_selected")
        return check
    }()
    
    lazy var lineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(hexString: "#EFEFEF")
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.backgroundColor = UIColor.clear
        lbl.textColor = UIColor.init(hexString: "#000000")
        lbl.alpha = 0.85
        lbl.font = FontPFRegularSize(16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
