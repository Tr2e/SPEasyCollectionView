# 说在最前：还有很多应用层面上的不足，会陆续修复。如果有幸你戳进这个链接，希望解决问题的思路能帮到你

20170712：将collectionView属性外置 方便配合使用加载及刷新

```
- (void)manageRequest{
    
    self.productListView.collectionView.canRefresh = YES;
    self.productListView.collectionView.pageSize = 20;
    self.productListView.collectionView.canAutoLoadMore = YES;
    
    __weak typeof(self) ws = self;
    self.productListView.collectionView.refreshDataCallBack = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws.productListView.collectionView doneLoadDatas];
        });
    };
    self.productListView.collectionView.loadMoreDataCallBack = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws.productListView.collectionView doneLoadDatas];
        });    };
    
}
```

# SPEasyCollectionView
1.方便快速的构建`UICollectionView`,告别繁琐而丑陋的数据源、代理方法

2.支持链式传参

3.支持轮播

4.支持长按重排

![iOS8x-.gif](http://upload-images.jianshu.io/upload_images/1742463-4601a1c424019561.gif?imageMogr2/auto-orient/strip)
![cycle_pic.gif](http://upload-images.jianshu.io/upload_images/1742463-c85b0fdeb9160592.gif?imageMogr2/auto-orient/strip)
