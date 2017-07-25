
# SPEasyCollectionView
1.方便快速的构建`UICollectionView`,告别繁琐而丑陋的数据源、代理方法

2.支持链式传参

3.支持轮播

4.支持长按重排

![iOS8x-.gif](http://upload-images.jianshu.io/upload_images/1742463-4601a1c424019561.gif?imageMogr2/auto-orient/strip)
![cycle_pic.gif](http://upload-images.jianshu.io/upload_images/1742463-c85b0fdeb9160592.gif?imageMogr2/auto-orient/strip)

使用示例：

<strong> 链式 </strong>
```
    // 基本样式
    CGRect contentframe = self.centerContentView.bounds;
    CGFloat itemWidth = (contentframe.size.height - 3*itemMargin)/4.0;
    CGSize itemSize = CGSizeMake(itemWidth, itemWidth);
    
    SPEasyCollectionView *brandSelect = [[SPEasyCollectionView alloc] initWithFrame:self.centerContentView.bounds];
    brandSelect.sp_inset(^UIEdgeInsets{
        return UIEdgeInsetsMake(0, 15, 0, 15);
    }).sp_xibName(^NSString *{
        return @"BrandSelectCell";
    }).sp_delegate(^id{
        return ws;
    }).sp_itemsize(^CGSize{
        return itemSize;
    }).sp_minLineSpace(^NSInteger{
        return itemMargin;
    }).sp_minInterItemSpace(^NSInteger{
        return itemMargin;
    }).sp_scollDirection(^SPEasyScrollDirection{
        return SPEasyScrollDirectionHorizontal;
    }).sp_backgroundColor(^UIColor *{
        return [UIColor clearColor];
    });
    
    brandSelect.datas = datas;
    brandSelect.alpha = 0;
    
    [self.centerContentView addSubview:brandSelect];
    self.brandSelectView = brandSelect;
```
<strong> 普通 </strong>
```
    // 代码创建 轮播
    SPEasyCollectionView *easyView = [[SPEasyCollectionView alloc] 
    initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 200)];
    easyView.delegate = self;
    easyView.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    easyView.scrollDirection = SPEasyScrollDirectionHorizontal;
    easyView.xibName = @"EasyCell";
    easyView.needAutoScroll = YES;
    easyView.datas = @[@"1",@"2",@"3",@"4"];
    easyView.minLineSpace = 0;//务必设置此参数，否则会造成轮播后期偏移误差
    [self.view addSubview:easyView];
```

### 特别需要注意的是 因为将reload方法绑定在Setdata方法中执行而且storyboard特殊的执行顺序，所以希望务必将`xx.datas = @[]`放在配置参数最后调用

### 如果使用这个封装的话，请将你的CollectionViewCell或者你的ReuseView 都继承自`SPBase`

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
![SupplementaryView](https://github.com/Tr2e/SPEasyCollectionView/raw/master/supplement.png)
