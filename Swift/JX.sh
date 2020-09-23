# mvvm.sh

authorInfoFunc() {
    mdate=`date +%Y/%m/%d`
    year=${mdate%%/*}
    info="//\n//    $1\n//  Project\n//\n//  Created by ${USER} on ${mdate}.\n//  Copyright © ${year} xiaoniu88. All rights reserved.\n//\n
"
    echo $info
}

createPageVCFiles() {
    subVC=$1VC
    viewController=$1PageVC
    entity=$1Model
    authorInfo=`authorInfoFunc ${viewController}.swift`

    # 创建.m
echo "${authorInfo}

import UIKit
import JXPagingView
import JXSegmentedView

enum $1Type : Int {
    case one
    case two
}

class ${viewController}: XBaseViewController {

    lazy var subVCS : [$subVC] = {
        // TODO:
        return [${subVC}(type: .one),${subVC}(type: .two)]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""

        // 下拉刷新要处理，加载更多直接触发childVC的
        pagingView.mainTableView.setHeaderRefresh({ [weak self] in
            self?.sendDefaultRequest()
            self?.subVCS[self.segControl.selectedIndex].reloadData()
        })

        for vc in self.subVCS {
            vc.vm.endSubject.subscribe(onNext: { [weak self](status) in
                self?.pagingView.mainTableView.endRefresh()
            }).disposed(by: self.disposeBag)
        }
    }

    override func setupSubviews() {
        super.setupSubviews()
        self.view.addSubview(self.pagingView)
    }
    
    override func setupConstriants() {
        super.setupConstriants()
        
        pagingView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.left.right.equalToSuperview()
                make.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
        }
    }

    //MARK: - Subviews
        
    private lazy var pagingView: JXPagingView = {
        let view = JXPagingView(delegate: self)
        view.frame = CRScreenBounds()
        view.mainTableView.gestureDelegate = self
        view.backgroundColor = .clear
        view.mainTableView.backgroundColor = .clear

        return view
    }()

    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()

        dataSource.titles = ["",""]
        dataSource.titleNormalColor = .white
        dataSource.titleNormalFont = .pingFangRegular(ofSize: 15)
        dataSource.titleSelectedColor = .white
        dataSource.titleSelectedFont = .pingFangRegular(ofSize: 15)
        dataSource.isTitleZoomEnabled = false
        dataSource.isItemWidthZoomEnabled = false
        return dataSource
    }()

    private lazy var segControl: JXSegmentedView = {
        let seg = JXSegmentedView()
        seg.frame = CGRect(x: 0, y: 12, width: 60, height: 44)
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorCornerRadius = 1
        indicator.indicatorColor = .white
        indicator.indicatorHeight = 3
        indicator.indicatorWidth = 30
        seg.indicators = [indicator]
        
        seg.backgroundColor = UIColor.qd_background
        seg.dataSource = segmentedDataSource
        seg.listContainer = self.pagingView.listContainerView
        seg.isContentScrollViewClickTransitionAnimationEnabled = false
        
        return seg
    }()
}

extension ${viewController}: JXPagingViewDelegate {

    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return 0
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return UIView.init()
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        44
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
         segControl
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        segmentedDataSource.titles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
         return self.subVCS[index]
    }
}

extension ${viewController}: JXPagingMainTableViewGestureDelegate {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
        if otherGestureRecognizer == segControl.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}

" >> ${viewController}.swift
}

createEntityFiles() {
entity=$1"Model"
authorInfo=`authorInfoFunc ${viewModel}.swift`
# 创建model.swift
echo "${authorInfo}

import HandyJSON

class $entity : HandyJSON {
    required init() {
        
    }
}

" >> $entity".swift"
}


createViewModelFiles() {
    
    entity=$1"Model"
    viewModel=$1ViewModel
    authorInfo=`authorInfoFunc ${viewModel}.swift`

    echo "${authorInfo}

class ${viewModel}: PageContainerDataRefreshViewModel<${entity}> {

    // type=1进行中 2 已完成
    var type : Int = 1
    
    convenience init(type:Int) {
        self.init()
        
        self.type = type
    }
    
    override func refreshPageDataAPI(page: Int, limit: Int) -> Single<ResponseModel<PageContainerModel<${entity}>>> {
        let api = GloveAPI.selectMyScrollList(type: type)
        return Network.request(api,dataType: ResponseModel<PageContainerModel<${entity}>>.self)
    }
}

" >> ${viewModel}.swift

}


createVCFiles() {

    entity=$1"Model"
    viewModel=$1ViewModel
    viewController=$1VC
    cell=$1Cell
    authorInfo=`authorInfoFunc ${viewController}.swift`

echo "${authorInfo}

import UIKit

class ${viewController}: XMVVMTableVC<${entity}> {

    var type : $1Type = .one
	lazy var vm = $1ViewModel(type: self.type.rawValue)

    convenience init(type: $1Type) {
        self.init()
        self.type = type
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = \"\"
        
        setupViewModel()
        viewModel.refreshData()
    }

    func reloadData() {
        self.vm.refreshData()
    }
        
    func setupViewModel() {
        viewModel = self.vm
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ${cell}.cell(for: tableView) as! ${cell}
        cell.selectionStyle = .none
        cell.config(model: self.viewModel.dataList[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ${cell}.cellHeight()
    }
    
}
" >> ${viewController}.swift

}


createCellFiles() {

    entity=$1"Model"
    viewModel=$1ViewModel
    viewController=$1VC
    cell=$1Cell
    echo "
${authorInfo}

import UIKit

class ${cell}: XTableViewCell {
    
    var model : ${entity}?

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func config(model:${entity}) {
        self.model = model

    }

    class func cellHeight() -> CGFloat {
        return 60
    }
}
" >> ${cell}.swift

cat >> ${cell}.xib <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0" toolsVersion="16097.2" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" colorMatched="YES">
    <device id="retina6_1" orientation="portrait" appearance="light"/>
    <dependencies>
        <deployment identifier="iOS"/>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="16087"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <objects>
        <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner"/>
        <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder"/>
        <tableViewCell contentMode="scaleToFill" selectionStyle="default" indentationWidth="10" id="KGk-i7-Jjw" customClass="XEmptyTableViewCell" customModule="臻御生态" customModuleProvider="target">
            <rect key="frame" x="0.0" y="0.0" width="320" height="44"/>
            <autoresizingMask key="autoresizingMask" flexibleMaxX="YES" flexibleMaxY="YES"/>
            <tableViewCellContentView key="contentView" opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center" tableViewCell="KGk-i7-Jjw" id="H2p-sc-9uM">
                <rect key="frame" x="0.0" y="0.0" width="320" height="44"/>
                <autoresizingMask key="autoresizingMask"/>
            </tableViewCellContentView>
            <point key="canvasLocation" x="139" y="153"/>
        </tableViewCell>
    </objects>
</document>
EOF

sed -i "" "s/XEmptyTableViewCell/$1Cell/g" `pwd`"/${cell}.xib"

}


if [[ -n $1 ]]; then
echo $1
#创建一个目录

mkdir $1
cd $1

createPageVCFiles $1
createVCFiles $1
createEntityFiles $1
createViewModelFiles $1
createCellFiles $1

path=`pwd`

osascript <<EOF

set a to  POSIX file "$path"
tell application "Finder"
    open folder a
end tell
EOF

else

    echo "please input model name"

fi






