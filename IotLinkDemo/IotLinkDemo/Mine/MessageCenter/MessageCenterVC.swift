////
////  MessageCenterVC.swift
////  AgoraIoT
////
////  Created by FanPengpeng on 2022/5/12.
////
//
//import UIKit
//import AgoraIotLink
//import JXSegmentedView
//
//
//class MessageCenterVC: AGBaseVC {
//
//    var device: IotDevice?
////    private let alamMsgVC = DoorbellMessageVC()
////    private let notifyMsgVC = NotifyMessageVC()
//
//    var alamUnreadCount = 0
//    var notifyUnreadCount = 0
//
//    var segmentedDataSource: JXSegmentedNumberDataSource?
//    let segmentedView = JXSegmentedView()
////    lazy var listContainerView: JXSegmentedListContainerView! = {
////        return JXSegmentedListContainerView(dataSource: self)
////    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.title = "消息"
//        view.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
//
//        //配置数据源
//        let dataSource = JXSegmentedNumberDataSource()
//        dataSource.isTitleColorGradientEnabled = true
//        dataSource.titles = ["告警消息","通知消息"]
//        dataSource.numbers = [alamUnreadCount,notifyUnreadCount]
//        dataSource.titleNormalColor = UIColor(hexRGB: 0x000000, alpha: 0.4)
//        dataSource.titleSelectedColor = UIColor(hexRGB: 0x000000)
//        segmentedDataSource = dataSource
//
//        let indicator = JXSegmentedIndicatorLineView()
//        indicator.indicatorWidth = 20
//        indicator.indicatorColor = UIColor(hexRGB: 0x1DD6D6)
//        segmentedView.indicators = [indicator]
//        segmentedView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
//
//        segmentedView.dataSource = dataSource
//        segmentedView.delegate = self
//
//        view.addSubview(segmentedView)
//        segmentedView.snp.makeConstraints { make in
//            make.left.top.right.equalToSuperview()
//            make.height.equalTo(50)
//        }
//
//        segmentedView.listContainer = listContainerView
//        view.addSubview(listContainerView)
//        listContainerView.snp.makeConstraints { make in
//            make.left.bottom.right.equalToSuperview()
//            make.top.equalTo(segmentedView.snp.bottom)
//        }
//
//        let lineView = UIView()
//        lineView.backgroundColor = UIColor(hexRGB: 0xE5E5E5)
//        view.addSubview(lineView)
//        lineView.snp.makeConstraints { make in
//            make.left.right.equalTo(segmentedView)
//            make.top.equalTo(segmentedView.snp.bottom)
//            make.height.equalTo(1)
//        }
//    }
//
//    //MARK: 数字刷新demo
//    @objc func hanldeNumberRefresh()
//    {
//        if let _segDataSource = segmentedDataSource {
//            let newNumbers = [alamUnreadCount, notifyUnreadCount]
//            _segDataSource.numbers = newNumbers
//            segmentedView.reloadDataWithoutListContainer()
//        }
//    }
//
//}
//
//extension MessageCenterVC: JXSegmentedViewDelegate {
//
//    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
//    }
//}
//
////extension MessageCenterVC: JXSegmentedListContainerViewDataSource {
////    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
////        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
////            return titleDataSource.dataSource.count
////        }
////        return 0
////    }
////
////    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
////        switch index {
////        case 1:
////            notifyMsgVC.unreadValueChanged = {[weak self] in
////                guard let wSelf = self else { return }
////                if wSelf.notifyUnreadCount > 0 {
////                    wSelf.notifyUnreadCount -= 1
////                    wSelf.hanldeNumberRefresh()
////                }
////            }
////            return notifyMsgVC
////        default:
////
////            alamMsgVC.bgStyle = .white
////            alamMsgVC.playerStyle = .none
////            alamMsgVC.unreadValueChanged = {[weak self] in
////                guard let wSelf = self else { return }
////                if wSelf.alamUnreadCount > 0 {
////                    wSelf.alamUnreadCount -= 1
////                    wSelf.hanldeNumberRefresh()
////                }
////            }
////            return alamMsgVC
////        }
////    }
////}
