
# SPEasyCollectionView
1.方便快速的构建`UICollectionView`,告别繁琐而丑陋的数据源、代理方法

2.支持链式传参

3.支持轮播

4.支持长按重排

![iOS8x-.gif](http://upload-images.jianshu.io/upload_images/1742463-4601a1c424019561.gif?imageMogr2/auto-orient/strip)
![cycle_pic.gif](http://upload-images.jianshu.io/upload_images/1742463-c85b0fdeb9160592.gif?imageMogr2/auto-orient/strip)

### 特别需要注意的是 因为将reload方法绑定在Setdata方法中执行而且storyboard特殊的执行顺序，所以希望务必将`xx.datas = @[]`放在配置参数最后调用

### 20170724：添加CollectionView中`SupplementaryView`的支持 更新具体Api如下
```
// Register Header
@property (nonatomic, copy) NSString *headerXibName;
@property (nonatomic, copy) NSString *headerClassName;
// Register Footer
@property (nonatomic, copy) NSString *footerXibName;
@property (nonatomic, copy) NSString *footerClassName;
// Header Size
@property (nonatomic, assign) CGSize headerSize;
// Footer Size
@property (nonatomic, assign) CGSize footerSize;
```
