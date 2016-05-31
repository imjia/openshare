//
//  UIScrollView+TCPullToRefresh.h
//  TCKit
//
//  Created by dake on 15/4/26.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPullToRefresh.h"

@interface UIScrollView (TCPullToRefresh) <TCPullToRefresh, TCRefreshHeaderViewDelegate>

@property (nonatomic, assign) TCLoadDataType loadType;
@property (nonatomic, assign) TCPullRefreshMode listMode;

@property (nonatomic, assign) BOOL refreshEnabled; /**< 下拉刷新功能开关 */
@property (nonatomic, assign) BOOL loadMoreEnabled; /**< 上拉翻页功能开关 */
@property (nonatomic, assign) BOOL reloading; /**< 正加刷新 */
@property (nonatomic, assign, readonly) BOOL loadingMore; /**< 正在加载下一页 */

@property (nonatomic, strong, readonly) UIView<TCRefreshHeaderInterface> *refreshHeaderView;

@property (nonatomic, assign) id<TCPullToRefreshDelegate> pullRefreshDelegate;


- (BOOL)tc_triggerReload:(BOOL)animated;
- (BOOL)tc_triggerLoadMore;

- (void)tc_scrollViewDidScroll:(UIScrollView *)scrollView;
//- (void)tc_scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)tc_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end
