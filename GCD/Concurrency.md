# iOS 多线程编程：使用 NSOperation 和 GCD 进行多线程编程
在 iOS 开发中,并发通常被视作"洪水猛兽"。许多开发者认为这是"危险地带",因此都极力避免使用它。传闻多线程代码应该尽你所能去避免使用。我也认为在你没有很好掌握并发编程的时候,这的确是一个"危险地带"。它的不安全来源于你的无知。想象一下,在人们的一生中,也要面临很多的危险活动,不是么?但是一旦人们掌握了它(技巧),你将能很好的使用它。并发编程拥有两面性,因为你应该掌握如何去使用它。它帮助你构建出有执行效率高,快速的应用,同时,滥用也会导致是你的应用崩溃。这就是为什么在开始使用并发编程技术之前你应该了解哪些 API 可以用来解决问题。在iOS 中有不同的APIs 可供使用。在这篇教程中我们将会介绍我们经常使用的两种 APIs ---- NSOperation 和 Dispatch Queues。 
## 为什么要使用并发?
我知道你是一个有丰富经验的 iOS 开发者。无论你将要开发什么类型的 apps ,你都需要知道并发编程可以是你的应用运行的更快更高效。以下我简要列举几个使用并发的有点:
* **充分利用 iOS 的硬件** : 现在所有的 iOS设备都拥有多核处理器, 这就允许开发者可以并行执行多个任务。所以你应该充分利用这一点(多核处理器),发挥硬件的优势。
* **更好的用户体验**:有时候你会去调用网络服务,进行一些 IO 操作, 或者执行一些其它繁重的事务。如你所知, 在 UI 线程(main thread)做这些操作将会阻塞你的应用, 是程序失去响应。曾经用户面对过这个问题,
他会立马杀掉应用进程。使用多线程,所有这些事务都可以在后台线程完成无需阻塞主线程以及妨碍用户操作。用户可以同时点击按钮,滑动操作应用。
* **NSOpetion 和 GCD 的 APIs 使得多线程编程变得更加简单**:创建和管理线程是一件不容易的任务。这也就是为什么大多数的开发者听到多线程以及并发的时候感到恐惧的原因。在 iOS 开发中, 我们有很多优雅易用的并发 APIs。你无须关心底层如何实现创建或者管理线程。这些 APIs 将会为你做好一切。另外一个重要的优势就是,这些 APIs 帮你完成同步操作来避免竞态条件的发生。当多线程操作一份共享的数据时候可能会发生竞态条件,从而导致意想不到的结果。通过使用synchronization 来保护在多线程之间共享的资源。
## 关于并发你应该知道哪些?
在本教程中, 我们将会向你解释所有你应该掌握理解以及困惑你的知识点。首先我推荐了解 blocks(Swift中的闭包),因为在并发的 APIs 中大量使用到了。然后我们将会讲解 GCD 和 NSOpertionQueues 。我们将会讲解他们的概念,不同以及如何去实现。
## 第一部分:GCD (Grand Central Dispatch)
GCD 最常使用用来管理并发,执行异步任务的 API , GCD 提供以及管理着任务队列。首先, 让我们来看看都有哪些队列。
### 队列是什么?
队列是一种管理对象先入先出(FIFO)的数据结构。队列类似于电影院购票窗口排队的人群。 电影票以先到先被服务的形式进行售卖。队列前边的人比后边的人先买到票。计算机中队列也是类似的,因为先添加进队列的元素首先被移除。
![](http://www.appcoda.com/wp-content/uploads/2015/10/queue-line-2-1166050-1280x960.jpg)
### Dispatch Queues
Dispatch Queues 可以让你在你的应用中很便捷的使用异步以及并发。你的应用以 blocks 的形式来调用这些队列。有两种形式的 dispatch queues：(1)serial queue(串行队列)，以及(2)concurrent queues(并发队列)。在讨论两者的不同之前，亦需要首先知道任务被分配在单独的线程执行，而不是创建线程的线程。也就是说，假如你在主线程创建 dispatch queues，这些任务会在运行的其他的线程上，而不是主线程上。
### Serial Queues
当你选择使用串行队列，这种队列只能同时执行一个任务。在一个串行队列中的所有任务都会按顺序执行。然而，他们不关心在其他线程上的任务，也就是说你可以使用多个串行队列。比如，你可以创建两个穿行队列，每一个队列同一时间只能执行一个任务，但是两个任务(不同线程上的)可以同时被执行(并发)。
串行队列对于管理共享的资源来说简直太棒啦！对于共享的资源，它提供了按序的保障来避免"竞态条件"的发生。想象一下，有一大群要买电影票的人，但是只有一个售票厅，在这个例子中，售票员就是共享的资源。一个人同时服务这么多人简直太糟了。为了解决这种窘境，就要求买票的排成一个队列(serial queue)，以便售票员同一时间只服务一个人。
再次强调，这并不意味着电影院同时只能服务一个人。如果新开放了两个的柜台，那么就可以同时服务三个顾客。这就是所说的通过使用多个串行队列来实现同时可以执行多任务。
串行队列的优势：
 1.  对共享资源有序的访问可以避免"竞态条件";
 2.  任务在可控的秩序下执行。当你递交一个任务到串行队列，它们将会按照你添加的队列被执行。
 3.  你可以创建任意数量的串行队列。
 ### Concurrent Queues
 正如名字一样，并发队列允许同时执行多个任务。任务在他们被添加到的队列上有序执行。但是他们的执行可以同时进行并且无需等待其他任务直接执行。并发队列以同一个次序下执行，但是你不知道执行的具体次序，执行时间以及有几个任务在同时执行。
 举个栗子，并发队列执行三个任务(任务#1，任务#2，任务#3)。这些任务在队列中以他们添加的顺序同时执行，然而，执行时间以及结束时间是不同的。即时#2和#3任务开始耗费了一些时间，他们依然可以先于#1任务完成。这是由操作系统来决定的。
 ### 使用队列
 现在我们已经解释了串行和并行队列，该了解如何使用它们了！系统给每一个应用默认提供一个串行队列以及四个并行队列。主队列是运行在主线程上全局可用的串行队列;它被用来更新 app UI 以及和 UIView 更新相关的操作。主队列只能同时执行一个任务，这就是为什么在主线程上执行繁重的任务会阻塞你的 UI 操作。
 除了主队列, 系统还提供了四个并发队列。我们称之为 `Global Dispatch     Queue` 。这些队列在应用程式中是全局的，并且只在优先级上有区别。使用这些全   局队列，你需要使用以下值来指定 `dispatch_get_global_queue` 的第一个参数:
* `DISPATCH_QUEUE_PRIORITY_HIGH`
* `DISPATCH_QUEUE_PRIORITY_DEFAULT`
* `DISPATCH_QUEUE_PRIORITY_LOW`
* `DISPATCH_QUEUE_PRIORITY_BACKGROUND`
这些队列类型相当于执行的优先级。HIGH 具备最高优先级，BACKGROUND 拥有最低的优先级。因此你可以以此来决定你所使用的队列的优先级。同时请注意，这些队列使用的是 Apple 的 APIS，因此这些队列执行的不仅只有你的任务。
总结, 你可以创建任意数量的串行或者并行队列。在使用并发队列的时候，我强烈建议使用系统提供的四种全局队列，当然你也可以创建你自己的队列。

## CGD 图表
现在你应该对 `dispatch queue` 有了初步的理解。现在, 我将会给你一个简单的图表供你参考。这个表格很简单, 包含了所有你需要了解关于 GCD 的知识点。
![](http://www.appcoda.com/wp-content/uploads/2015/10/gcd-cheatsheet.png)

非常 cool，对吧？现在让我们编写一个简单的 demo 来了解如何使用 dispatch queues 。我将会展示给你如何使用 dispatch queues 来优化一个 app 的性能 使得其响应更快。
## Demo Project
我们的启动项目非常的简单，我们展示四个 image views ,每一个从指定站点请求一个图片。图片请求在主线程完成。为了展示给你 UI 是如何的响应, 我已经添加了简单的 slider 在图片下边。现在 [下载并运行项目](https://www.dropbox.com/s/lkiasutevec5vx0/ConcurrencyDemoStarter.zip?dl=0)。点击 Start 按钮来开始下载图片,然后拖动 slider 当图片下载的时候。你将会发现 slider 拖不动。
![](http://www.appcoda.com/wp-content/uploads/2015/10/concurrency-demo.png)
在你点击了开始按钮后, 图片在主线程开始瞎子啊。显而易见, 这种做法非常可怕, 并且使得 UI 无响应。不幸的是, 时至今日，仍然有很多 app 在主线做许多繁重的加载任务。现在让我们一起来使用 dispatch queues 来修复这个问题吧!
首先, 我们将要使用并发队列然后再使用串行队列来实现解决方案。
### 使用并发队列
先在 Xcode 中打开 `ViewController.swift`。如果你仔细看了代码的话，你会看到 `didClickOnStart` 方法。这个方法进行了图片下载。我们现在执行任务如下所示：
    
    @IBAction func didClickOnStart(sender: AnyObject) {
        let img1 = Downloader.downloadImageWithURL(imageURLs[0])
        self.imageView1.image = img1
    
        let img2 = Downloader.downloadImageWithURL(imageURLs[1])
        self.imageView2.image = img2
    
        let img3 = Downloader.downloadImageWithURL(imageURLs[2])
        self.imageView3.image = img3
    
        let img4 = Downloader.downloadImageWithURL(imageURLs[3])
        self.imageView4.image = img4
    }
每一个 downloader 都被视作一个任务,所有的任务都在主线程执行。现在让我们使用全局并发队列中的 Default 级别的队列。

    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
        disptach_asnc(queue) {() -> Void in
            let img1 = Downloader.downloadImageWithURL(imageURLS[0])
            dispatch_asnc(dispatch_get_main_queue(),{
                self.imageView1.image = img1
            })
        }
我们首先通过 `dispatch_get_global_queue` 来调用默认级别的并发队列, 然后在 block 里边我们递交了下载第一个图片的任务。当图片下载完成后,我们在主线程执行了使用下载的图片更新 image view的任务。也就是说,我们把下载任务放在一个后台线程中,但是在主线程中执行 UI 操作。
如果你剩余的图片进行了同样的操作,你的代码应该和下边一样:
        @IBAction func didClickOnStart(sender: AnyObject) {
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { () -> Void in
            
            let img1 = Downloader.downloadImageWithURL(imageURLs[0])
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView1.image = img1
            })
            
        }
        dispatch_async(queue) { () -> Void in
            
            let img2 = Downloader.downloadImageWithURL(imageURLs[1])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView2.image = img2
            })
            
        }
        dispatch_async(queue) { () -> Void in
            
            let img3 = Downloader.downloadImageWithURL(imageURLs[2])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView3.image = img3
            })
            
        }
        dispatch_async(queue) { () -> Void in
            
            let img4 = Downloader.downloadImageWithURL(imageURLs[3])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView4.image = img4
            })
        }
        
    }
现在你已经把四个图片下载任务放在了一个并发队列里。然后编译运行你的 app ,他应该运行的很快(如果跑出了异常,你应该检查你的代码是否和上边一样)。注意到了吗?当你在下载图片的时候,你依然可以很顺畅的拖拽 slider 。
### 使用串行队列
解决阻塞的另一种方法是使用串行队列。现在同样定位到 ViewController.swift 的 `didClickOnStart` 方法。这次我们将使用串行队列来下载图片。当使用串行队列的时候,你应当注意你应该使用哪个串行队列。每一个 app 都有一个默认的串行队列, 也就是进行 UI 操作的主队列。所以记得在使用串行队列的时候,应该创建一个新的串行队列。否则你将会在你的 app 更新 UI 的时候执行任务,这将会导致毁掉用户体验。你可以使用 `dispatch_queue_create` 来创建新的队列然后像之前我们的操作一样来执行任务。代码如下所示:
    @IBAction func didClickOnStart(sender: AnyObject) {
        
        let serialQueue = dispatch_queue_create("com.appcoda.imagesQueue", DISPATCH_QUEUE_SERIAL)
        
        
        dispatch_async(serialQueue) { () -> Void in
            
            let img1 = Downloader .downloadImageWithURL(imageURLs[0])
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView1.image = img1
            })
            
        }
        dispatch_async(serialQueue) { () -> Void in
            
            let img2 = Downloader.downloadImageWithURL(imageURLs[1])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView2.image = img2
            })
            
        }
        dispatch_async(serialQueue) { () -> Void in
            
            let img3 = Downloader.downloadImageWithURL(imageURLs[2])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView3.image = img3
            })
            
        }
        dispatch_async(serialQueue) { () -> Void in
            
            let img4 = Downloader.downloadImageWithURL(imageURLs[3])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView4.image = img4
            })
        }
        
    }
正如我们所看到的一样, 并行队列和串行队列只有创建方式不同。当我们再次运行我们的 app,图片依然在后台线程下载,所以我们可以操作我们 UI。
但是,请注意以下两点:
1.  这会比并发队列耗时更多,因为我们同一时间只下载了一张图片。每一个任务都在等待前一个任务的结束。
2.  图片以 image1, image2, image3, image4的顺序下载。因为这是一个串行队列,同一时间只有一个任务在执行。
## 第二部分: Operation Queues
GCD 是开发者可以并发执行任务的底层 C API。Operation queues,是建立 GCD 之上的高级抽象队列模型。这意味着你可以像 GCD 那样并发执行任务,但是是以面向对象的方式。简而言之, Operation queues 是的开发者更加轻松 ;)。
不像 GCD 那样, Operation Queues 不遵循 FIFO 的规则。以下列举几点 operation queues 和 dispatch queues 之间的不同点:
1.  不遵循 FIFO: 在 operation queues 中,你可以设置任务执行的优先级,也可以添加任务间的依赖关系,这意味着你可以定义一些任务在别的任务之后。这就是为什么它不遵循 FIFO 的原因。
2.  默认情况下,它们是并发执行的:虽然你们使他们变为串行队列,但是你仍然可以通过设置任务依赖关系来实现。
3.  Operation queues 是 `NSOperationQueue` 的实例, 同时任务是 `NSOpreation` 的实例。

### NSOperation
operation queues 里的任务是以 `NSOpreation`实例的形式进行递交。我们讨论过在 GCD 中任务是以 block 的形式递交的,同样也可以在这儿使用,但是必须和 [NSOperation](https://developer.apple.com/documentation/foundation/operation) 实例一起使用。你可以简单的把 NSOperation 看做一个工作单元。
NSOperation 是一个抽象类,所以不能直接使用,取而代之的是它的子类。在 iOS SDK 中,提供了两种 NSOperation 的子类。这些类可以直接被使用,但是你也可以自定一个 NSOperation 的子类来执行任务。我们可以直接使用的两个类如下:
1. **NSBlockOperation** - 通过这个类,使用一个或多个 blocks 来初始化任务。任务本身可以包含一个或多个 block,当所有的 block 执行完毕我们可以认为任务执行结束。
2. **NSInvocationOperation** - 使用这个来初始化一个任务,使得指定的对象执行一个 selector。

NSOperation 的优势有哪些?
1. 首先,NSOperation 支持添加依赖关系,通过使用` addDependency(op:NSOperation)` 方法。当你执行一个依赖其他任务的任务时,你应该使用 NSOperation。
![](http://www.appcoda.com/wp-content/uploads/2015/10/NSOperation-Fig2.png)
2. 其次,可以通过设置 以下几种 `queuePriority` 来改变任务执行的优先级:

        public enum NSOperationQueuePriority : Int {
            case VeryLow
            case Low
            case Normal
            case High
            case VeryHigh
        }

hight priority 的任务将会被首先执行。

3. 可以取消任意队列中指定的任务或者所有的任务。任务可以在被加入到队列后进行取消。在 NSOperation 类中只需要调用 `cancel()` 即可取消任务。当你取消了任意的任务,以下三种情况会有一种发生:
    - 你的任务已经完成。在这种情况下,取消操作没有任何反应。
    - 任务已经在执行。这种情况下,系统会强制停止你的任务, cacelled 属性将会被设置为 `true`。
    - 你的任务还在等待被执行。这种情况下,你的任务不会被执行。

4. NSOperation 有三个很有用的属性: finished, cancelled以及 ready。当任务执行完成后 finished 属性会被设置为 true。cancelled 属性会在任务取消的时候被设置为 true。ready 会在任务等待被执行的时候被设为 true。
5. 任何的 NSOperation 都可以设置一个完成的回调 (completion block)。当 finished 属性被设为 true 的时候这个 block 将被执行。

现在让我们使用 NSOperation 来重写我们的 demo。首先在 Viewcontroller 中声明一下变量:
 
    `var queue = NSOperationQueue()`

接着,用以下代码来取代 `didClickOnStart` 方法,并观察我们在 NSOperationQueue 中如何操作任务:

    @IBAction func didClickOnStart(sender: AnyObject) {
        queue = NSOperationQueue()
    
        queue.addOperationWithBlock { () -> Void in
            
            let img1 = Downloader.downloadImageWithURL(imageURLs[0])
    
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView1.image = img1
            })
        }
        
        queue.addOperationWithBlock { () -> Void in
            let img2 = Downloader.downloadImageWithURL(imageURLs[1])
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView2.image = img2
            })
    
        }
        
        queue.addOperationWithBlock { () -> Void in
            let img3 = Downloader.downloadImageWithURL(imageURLs[2])
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView3.image = img3
            })
    
        }
        
        queue.addOperationWithBlock { () -> Void in
            let img4 = Downloader.downloadImageWithURL(imageURLs[3])
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView4.image = img4
            })
    
        }
    }


正如以上你看到的, 使用`addOperationWithBlock` 方法给定的 block(swift 中的闭包)来创建新的任务。很简单,不是么?在主线程中执行任务,GCD 中我们使用 dispatch_async(),这里我们可以使用 `NSOperationQueue.mainQueue()` 取而代之。
你可以测试运行一下 demo, 如果代码运行正常, app 应该会在后台线程下载图片不会阻塞 UI 操作。
在上一个例子中,我们使用`addOperationWithBlock` 来向队列中添加任务。接下来让我们使用`NSBlockOperation` 来实现同样的操作,但是同时我们有更多可选择的(比如 completing handler)block。`didClickOnStart` 方法重写如下:

    @IBAction func didClickOnStart(sender: AnyObject) {
        
        queue = NSOperationQueue()
        let operation1 = NSBlockOperation(block: {
            let img1 = Downloader.downloadImageWithURL(imageURLs[0])
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView1.image = img1
            })
        })
        
        operation1.completionBlock = {
            print("Operation 1 completed")
        }
        queue.addOperation(operation1)
        
        let operation2 = NSBlockOperation(block: {
            let img2 = Downloader.downloadImageWithURL(imageURLs[1])
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView2.image = img2
            })
        })
        
        operation2.completionBlock = {
            print("Operation 2 completed")
        }
        queue.addOperation(operation2)
        
        
        let operation3 = NSBlockOperation(block: {
            let img3 = Downloader.downloadImageWithURL(imageURLs[2])
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView3.image = img3
            })
        })
        
        operation3.completionBlock = {
            print("Operation 3 completed")
        }
        queue.addOperation(operation3)
        
        let operation4 = NSBlockOperation(block: {
            let img4 = Downloader.downloadImageWithURL(imageURLs[3])
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView4.image = img4
            })
        })
        
        operation4.completionBlock = {
            print("Operation 4 completed")
        }
        queue.addOperation(operation4)
    }

对于每一个任务,我们创建一个新的`NSBlockOperation`实例来把任务包含在一个 block 里。现在当任务完成后果, completion handler 将会被调用。方便起见,我们将会在任务执行完毕后打印一个简短的提示。如果运行 demo, 你将会在控制台看见如下提示:

    Operation 1 completed
    Operation 3 completed
    Operation 2 completed
    Operation 4 completed

### 取消任务
正如之前所提及的,`NSBlockOperation` 允许你来管理任务。现在让我们看看如何取消任务。首先,我们在导航栏添加一个叫做 Cancle 的按钮。为了实现取消操作,我们将会在任务#2和任务#1添加依赖关系,并且在任务#2和任务#3天假依赖关系,这意味着#2将会在#1完成后开始,#3会在#2完成后开始。任务#4没有依赖关系将会并行执行。为了取消所有的任务,我们应该调用NSOperation 的 `cancleAllOperations()` 方法。在 ViewController 中添加一下方法:

    @IBAction func didClickOnCancel(sender: AnyObject) {
            
            self.queue.cancelAllOperations()
        }
别忘记关联刚才添加的取消按钮和`didClickOnCancel` 方法。然后在`didClickOnStart`方法中添加依赖关系:

    operation2.addDependency(operation1)
    operation3.addDependency(operation2)
接下来在任务#1中打印取消状态:
    operation1.completionBlock = {
                print("Operation 1 completed, cancelled:\(operation1.cancelled) ")
            }
同样应该记录#2#3#4的状态,以便可以看出执行过程。现在让我们继续运行。在点击了开始按钮后,按下取消按钮。这将会在#1完成后取消所有的任务。

- 任务#1 已经被执行,取消不会被执行。这就是为什么打印了取消状态为失败, app 仍然会加载图片#1。
- 如果点击取消按钮足够快,#2任务挥别取消。`cancelAllOpers()` 将会阻止#2任务的执行,因此#2图片没有被下载。
- #3任务已经被添加到了队列中,等待#2完成。但是#2被取消了,因此#3任务将不会被执行并且会被从队列中取出。
- 由于没有对任务#4进行配置,因此它将会一步执行下载任务。

![](http://www.appcoda.com/wp-content/uploads/2015/10/ios-concurrency-cancel-demo.png)
## 接下来要做的?
在本教程中,我已经帮你了解了 iOS 并发的概念,并告诉了你如何实现。我已经介绍了并发,解释了 GCD 并且展示怎么去创建并行队列和串行队列。我们也提及了NSOperationQueues。
为了更深入的理解 iOS 并发变成,我建议你学习[Apple's Concurrency Guide](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)。
你可以下载完整的代码[iOS 并发编程](https://github.com/appcoda/NSOperation-Demo)。

