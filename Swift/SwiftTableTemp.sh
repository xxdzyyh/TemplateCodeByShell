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

class ${viewModel}: PageContainerDataRefreshViewModel<${entity}> {

//    override func refreshPageDataAPI(page: Int, limit: Int) -> Single<ResponseModel<PageContainerModel<${entity}>>> {
//        let api = AssetsAPI.selectRechargeList(pageNum: page.string, pageSize: limit.string)
//        return Network.request(api,dataType: ResponseModel<PageContainerModel<${entity}>>.self)
//    }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = \"\"

        self.vm.dataList.append(${entity}())
        self.vm.dataList.append(${entity}())
        //self.vm.refreshData()
    }
        
    var vm : ${viewModel} = ${viewModel}()
    override func setupViewModel() {
        viewModel = self.vm
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ${cell}.cell(for: tableView) as! ${cell}
        cell.selectionStyle = .none
        cell.config(model: self.viewModel.dataList[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func config(model:${entity}) {
    	self.data = model

    }

    class func cellHeight() -> CGFloat {
        return 120
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





