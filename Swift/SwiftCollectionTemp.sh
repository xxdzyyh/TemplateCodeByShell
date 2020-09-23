# mvvm.sh

authorInfoFunc() {
	mdate=`date +%Y/%m/%d`
	year=${mdate%%/*}
	info="//\n//	$1\n//  sckj\n//\n//  Created by ${USER} on ${mdate}.\n//  Copyright © ${year} sckj.com. All rights reserved.\n//\n
"
	echo $info
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

//class ${viewModel}: DefaultDataRefreshViewModel<${entity}> {
//
//    override func refreshDataAPI(page: Int, limit: Int) -> Single<ResponseModel<[${entity}]>> {
//        let api = AssetsAPI.selectRechargeList(pageNum: page.string, pageSize: limit.string)
//        return Network.request(api,dataType: ResponseModel<[${entity}]>.self)
//    }
//}


class ${viewModel}: PageContainerDataRefreshViewModel<${entity}> {

    override func refreshPageDataAPI(page: Int, limit: Int) -> Single<ResponseModel<PageContainerModel<${entity}>>> {
        let api = AssetsAPI.selectRechargeList(pageNum: page.string, pageSize: limit.string)
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

class ${viewController}: XMVVMCollectionVC<${entity}> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = \"\"
        
        // viewModel必须先初始化再使用
        viewModel = $1ViewModel()
        viewModel.refreshData()
    }

    override func setupSubviews() {
        super.setupSubviews()
        
        self.collectionLayout.minimumLineSpacing = 10
        self.collectionLayout.minimumInteritemSpacing = 12
        self.collectionLayout.sectionInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.collectionLayout.itemSize = CGSize(width: self.view.width, height: 84)
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ${cell}.cell(for: collectionView, indexPath: indexPath) as! ${cell}
        cell.config(model: self.viewModel.dataList[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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

class ${cell}: XBaseCollectionViewCell {
    
    var data : ${entity}?

    override func awakeFromNib() {
    	super.awakeFromNib()

    }
    
    func config(model:${entity}) {
    	self.data = model

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
        <collectionViewCell opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center" id="gTV-IL-0wX" customClass="XEmptyCollectionCell" customModule="ZJVideo" customModuleProvider="target">
            <rect key="frame" x="0.0" y="0.0" width="50" height="50"/>
            <autoresizingMask key="autoresizingMask"/>
            <view key="contentView" opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center">
                <rect key="frame" x="0.0" y="0.0" width="50" height="50"/>
                <autoresizingMask key="autoresizingMask" flexibleMaxX="YES" flexibleMaxY="YES"/>
            </view>
            <point key="canvasLocation" x="139" y="153"/>
        </collectionViewCell>
    </objects>
</document>
EOF

}


if [[ -n $1 ]]; then
echo $1
#创建一个目录

mkdir $1
cd $1

	if [[ -n $2 ]]; then
	
		if [[ $2 = "vc" ]]; then
			createVCFiles $1
		elif [[ $2 = "cell" ]]; then
			createCellFiles $1
		elif [[ $2 = "vm" ]]; then
			createViewModelFiles $1
		elif [[ $2 = "model" ]]; then
			createEntityFiles $1
		fi
	else	
		createEntityFiles $1
		createViewModelFiles $1
		createVCFiles $1
		createCellFiles $1
	fi

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





