## Objective-C

```
# mvvm.sh

authorInfoFunc() {
	mdate=`date +%Y/%m/%d`
	year=${mdate%%/*}
	info="//\n//	$1\n//  BFMoney\n//\n//  Created by ${USER} on ${mdate}.\n//  Copyright © ${year} xiaoniu88. All rights reserved.\n//\n
"
	echo $info
}

createEntityFiles() {
mkdir Model
cd Model


entity=$1Entity
authorInfo=`authorInfoFunc ${entity}.h`

# 创建model.h
echo "${authorInfo}
#import \"$entity.h\"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface $entity : NSObject

@end

NS_ASSUME_NONNULL_END

" >> $entity".h"

# 创建Model.m
authorInfo=`authorInfoFunc ${entity}.m`
echo "${authorInfo}
#import \"${entity}.h\"

@implementation ${entity}


@end

" >> ${entity}.m

cd ..

}


createViewModelFiles() {

mkdir VM
cd VM

# 创建VM.h
viewModel=$1VM
authorInfo=`authorInfoFunc ${viewModel}.m`

	echo "${authorInfo}
#import \"BFBaseVM.h\"

NS_ASSUME_NONNULL_BEGIN

@interface $viewModel : BFBaseVM

- (instancetype)initWithEntity:(id)entity;

@end

NS_ASSUME_NONNULL_END
" >> ${viewModel}.h

	authorInfo=`authorInfoFunc ${viewModel}.m`

	# 创建VM.m
	echo "${authorInfo}

#import \"${viewModel}.h\"

@interface ${viewModel}()

@end

@implementation ${viewModel}

- (instancetype)initWithEntity:(id)entity {
	self = [super init];
    if (self) {
        
    }
    return self;
}

@end

" >> ${viewModel}.m

cd ..

}

createCellVMFiles() {
	viewModel=$1Cell
	createViewModelFiles $viewModel
}

createVCFiles() {
	# 创建.h
	mkdir VC
	cd VC

	viewController=$1VC
	authorInfo=`authorInfoFunc ${viewController}.m`

	echo "${authorInfo}
#import \"BFListVC.h\"
#import \"$1VM.h\"

NS_ASSUME_NONNULL_BEGIN

@interface $viewController : BFListVC

- (instancetype)initWithViewModel:($1VM *)viewModel;

@end

NS_ASSUME_NONNULL_END
" >> $viewController.h

	# 创建.m
	authorInfo=`authorInfoFunc ${viewController}.m`
	echo "${authorInfo}
#import \"$viewController.h\"
#import \"$1VM.h\"

@interface ${viewController}()

@property (nonatomic, strong) $1VM *viewModel;

@end

@implementation ${viewController}

#pragma mark - Initialize Methods

- (instancetype)initWithViewModel:($1VM *)viewModel {
	self = [super init];
    if (self) {
        _viewModel = viewModel;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];
    [self setupConstraints];
    [self setupEvent];
    [self showHudLoading];
    [self sendRequest];
}

#pragma mark - Super Methods

- (void)requestHandlerWishIsRefresh:(BOOL)isRefresh {
    [self sendRequest];
}

#pragma mark - Private Methods

- (void)sendRequest {

}

- (void)setupSubviews {

}

- (void)setupConstraints {
	
}

- (void)setupEvent {

}

#pragma mark - Event

#pragma mark - Property

@end

" >> ${viewController}.m
cd ..
}

createCellFiles() {
	mkdir View
	cd View

	cell=$1Cell
	authorInfo=`authorInfoFunc ${cell}.h`
	echo "${authorInfo}
#import \"BFBaseCell.h\"

NS_ASSUME_NONNULL_BEGIN
@interface $cell : BFBaseCell

- (void)setContentWithCellVM:(id)cellViewModel;

@end

NS_ASSUME_NONNULL_END
" >> ${cell}.h
	
	authorInfo=`authorInfoFunc ${cell}.m`
	echo "${authorInfo}
#import \"${cell}.h\"
#import \"$1CellVM.h\"

@interface ${cell}()

@end

@implementation ${cell}

#pragma mark - Initialize Methods

- (instancetype)initWithCellIdentifier:(NSString *)cellId {
	self = [super initWithCellIdentifier:cellId];
    if (self) {
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setupSubviews {

}

- (void)setupConstraints {

}

#pragma mark - Public Methods

- (void)setContentWithCellVM:(id)cellViewModel {
	$1CellVM *vm = cellViewModel;

}

+ (CGFloat)cellHeight {
    return scaleY(44);
}

#pragma mark - Property

@end

" >> ${cell}.m

cd ..

}


createViewFiles() {
	mkdir View
	cd View

	view=$1View
	authorInfo=`authorInfoFunc ${view}.h`
	echo "${authorInfo}
#import <UIKit/UIKit.h>

@class $1VM;

NS_ASSUME_NONNULL_BEGIN

@interface $view : UIView

- (instancetype)initWithVM:($1VM *)viewModel;

@end

NS_ASSUME_NONNULL_END
" >> ${view}.h
	
	authorInfo=`authorInfoFunc ${view}.m`
	echo "${authorInfo}
#import \"${view}.h\"
#import \"$1VM.h\"

@interface ${view}()

@property (nonatomic, strong) $1VM *viewModel;

@end

@implementation ${view}

#pragma mark - Initialize Methods

- (instancetype)initWithVM:($1VM *)viewModel {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _viewModel = viewModel;
        
        [self setupSubviews];
        [self setupConstraint];
        [self bind];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        [self setupConstraints];
        [self bind];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setupSubviews {

}

- (void)setupConstraints {

}

- (void)bind { 

}

#pragma mark - Public Methods


#pragma mark - Property


@end

" >> ${view}.m

cd ..

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
		elif [[ $2 = "cellVM" ]]; then
			createCellVMFiles $1
		elif [[ $2 = "vm" ]]; then
			createViewModelFiles $1
		elif [[ $2 = "model" ]]; then
			createEntityFiles $1
		elif [[ $2 = "view" ]]; then
			createViewFiles $1
		fi

	else	
		createEntityFiles $1
		createViewModelFiles $1
		createCellVMFiles $1
		createVCFiles $1
		createCellFiles $1
		createViewFiles $1
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


```

