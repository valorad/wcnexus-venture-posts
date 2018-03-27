---
title: "vue 实现滚动到元素位置才播放动画"
date: 2018-03-27T10:36:01+08:00
draft: false
tags: ["前端", "vue", "动画", "in-view"]
isCJKLanguage: true
---

我想实现的页面效果是，随着鼠标滑轮滚动，当某个元素（比如div）进入视野时，它动起来（比如淡入），而滑过这个元素时，就恢复原先的状态。我们下一次再看到它时，它再播放动画动起来。

# 效果图
gif

# 准备工作

这个例子采用了[vue-class-component]() + [typescript]()。当然你也可以用最基本的vue实现。

判断元素是否进入视野，我们主要将用到[in-view]()。
节流工作可以选择安装[rxjs]()

安装node包：

``` bash
yarn add in-view

#(可选)
yarn add rxjs
```

写一点小样式：
``` css
 /* styles.css */

.hideLeft {
  opacity: 0;
  transform: translateX(-3em);
}

.hideRight {
  opacity: 0;
  transform: translateX(3em);
}

.hideDown {
  opacity: 0;
  transform: translateY(5em);
}

```

# 动画状态

这里介绍的动画状态有2种情况：

1. 单个容器底下的所有元素
2. 动画组里的所有元素

我们把动画状态交由模板js的Boolean类型变量控制。实际上我们是用这些变量来开关对应元素的class，即我们准备好的`hideLeft`、`hideRight`等等。

但是当一个模板里面有大量的动画状态时，就会显得非常乱。所以我喜欢把他们集中到一个object里存放。像这样：

``` typescript

aniMap = {
  wikisec: {
    h1: true,
    p: true,
    picture: true
  },
  acfsec: [
    {
      name: "card1",
      hidden: true
    },
    {
      name: "card2",
      hidden: true
    },
    // ...
  ]
}

```

`wikisec` 即 情况1，这个object的key和元素的$ref名一样，object中有一系列动画开关。
`acfsec` 即情况2，object是一个数组，里面存放着动画组的一系列开关。`name`的值可以随便取。

# 实现看到才出现

我们把 单个容器底下的所有元素 和 动画组里的所有元素 这两种情况都拿来看看。

## 单个容器底下的所有元素

首先我们把html写出来

``` html
<!-- App.vue -->

<!-- 情况：单个容器底下的所有元素 -->
<!-- 指定ref便于后面js抓到这个容器 -->
<section class="wikisec" ref="wikisec">
  <div class="content">
    <div class="descr">
      <!-- :class来给每个容器底下的每个元素绑定开关 -->
      <!-- 这个class位置很重要，它只能元素的第1个class -->
      <h1 :class="{hideLeft: aniMap.wikisec.h1}">The Volunteer (The Witcher 3 secondary quests)</h1>
      <p :class="{hideLeft: aniMap.wikisec.h1}">Head out to White Eagle Fort, 
        ...
      </p>
    </div>
    <picture :class="{hideRight: aniMap.wikisec.h1}">
      <img src="./assets/Tw3_the_volunteer.jpg" alt="Tw3_the_volunteer" class="fluid">
    </picture>
  </div>
</section>
```

然后为容器添加样式，一定记得要给容器里的**每一个**元素加`transition`样式。

这里省略，你可以去看看这个例子的repo。

接下来是js部分。我们要实现的效果是

> 当某个元素（比如div）进入视野时，它动起来（比如淡入），而滑过这个元素时，就恢复原先的状态。

首先，怎么进入视野？这里我的想法是监视浏览器的滚动条，当滚动条滚动时，判断一下元素有没有进入视野。当然要指出哪些元素需要判断。

``` typescript
// App.vue
onWindowScroll = () => {
  console.log("发现窗口滚动，请注意节流");
  // 注册一下有哪些元素是进入视野才动画出现，这里用到了之前html里的ref
  this.animateWhenSeen(this.$refs.wikisec as Element);
}

// 在页面刚加载好时注册此行为
mounted() {
  window.addEventListener("scroll", this.onWindowScroll);
}

// 在页面卸载时删除此行为 （比如模板切换、路由切换等）
destroyed() {
  window.removeEventListener("scroll", this.onWindowScroll);
}

```

那么怎么判断元素进入了视野呢？这里我用到的是我们准备好的`in-view`。我们继续完成`animateWhenSeen`方法：

``` typescript
import inView from 'in-view';

animateWhenSeen(ele: Element){

  if(ele && inView.is(ele)) {
    // 此时元素可见，那么让它出现
    // 注意这里是反着的，false表示不隐藏
    this.switchElementAnimState( this.aniMap, ele.classList[0], false );
  } else {
    // 元素已经淡出视野，就恢复初始的状态
    this.switchElementAnimState( this.aniMap, ele.classList[0], true );
  }
  
};
```

当元素进入视野时，我们要让它出现。`switchElementAnimState`方法传入aniMap映射（就是开关集中object）、元素名称（ref值）以及开还是关。注意由于是控制对应元素的class，这里是反着的，“关”是“不隐藏”，“开”才是“隐藏”。

``` typescript
switchElementAnimState = (mapObject: any, eleName: string, switchTo: boolean) => {
  // 遍历所有key把对应value全部设置成switchTo的值
  for (let key in mapObject[eleName]) {
    mapObject[eleName][key] = switchTo;
  }
};
```

完成了。这时候你打开浏览器就可以看到这种效果。

[gif图]

## 动画组里的所有元素

与之前情况的区别是，动画组的开关存放在数组的object里，这样可以实现延时效果。

``` html 
<!-- App.vue -->

<!-- 情况：动画组里的所有元素 -->
<!-- 指定ref便于后面js抓到这个容器 -->
<section class="acfsec" ref="acfsec">
  <header>
    <h1>ac factions</h1>
  </header>
  <main>
    <div class="content">

      <!-- :class来给每个容器底下的每个元素绑定开关 -->
      <!-- 这个class位置很重要，它只能元素的第1个class -->
      <div class="card" :class="{hideDown: aniMap.acfsec[0].hidden}">
        <picture>
          <img src="./assets/ac-logo-ass.png" alt="ass" class="fluid">
        </picture>
        <h2>Hidden Ones</h2>
      </div>

      <div class="card" :class="{hideDown: aniMap.acfsec[1].hidden}">
        <picture>
          <img src="./assets/ac-logo-tmp.png" alt="tmp" class="fluid">
        </picture>
        <h2>Order</h2>
      </div>

      <!-- ……后面的元素是差不多的，省略了 -->

    </div>

  </main>
</section>
```

当动画组的根元素进入视野时：

``` typescript
animateGroupWhenSeen(ele: Element){

  if(ele && inView.is(ele)) {

    // 此时元素可见，那么让它出现
    // 注意这里是反着的，false表示不隐藏
    this.switchGroupAnimState(this.aniMap['acfsec'], 'hidden', false, 100 );

  } else {

    // 元素已经淡出视野，就恢复初始的状态
    this.switchGroupAnimState(this.aniMap['acfsec'], 'hidden', true, 100 );
    
  }
  
};
```

与上一种情况的区别是，对于动画组，我们要指定的是状态是个数组，指出管理状态的key名称，同时我们还可以指定出现的延迟时间。

``` typescript
switchGroupAnimState = (mapArray: any[], stateKey: string, switchTo: boolean, timeout: number = 100) => {

  for (let i = 0; i < mapArray.length; i++) {
    setTimeout(() => {
      mapArray[i][stateKey] = switchTo;
    }, i*timeout);
  }

};
```

大功告成，打开浏览器我们就可以看到相应的效果。

[gif]


# 触发节流

现在一切都似乎展现得flawlessly，但是，如果你打开控制台，你就会惊奇的发现：

[图]

我们每轻轻滚动一次鼠标，onscroll事件就要触发个10多20次，紧接着我们就要在那么十几个px的地方判断10多20次，这是有损性能且毫无意义的，所以我们要做好事件触发的节流工作。

你可以写一个简单的函数，用setTimeout来实现节流，不过那是前端面试题，你可以自己去瞅瞅，我在实际的项目中更多的是用**rxjs**来做节流工作，因为数据流更好管理。

对于我这种从隔壁[Angular]() 过来的前端喵，rxjs是很熟悉的。如果你不熟悉，你可以多 [了解了解rxjs]()

我们这里用rxjs代替addEventListener来管理这个onscroll事件。

``` typescript
// App.vue
import { Observable } from 'rxjs';
import 'rxjs/add/operator/throttleTime'; // <-- 关键
import { Subscription } from 'rxjs/Subscription';

windowScrolling = Observable.fromEvent(window, 'scroll'); // 窗口滚动事件交由rxjs管理
scrollSubscription: Subscription; // class里的成员存储一下这个订阅，便于后面unsubscribe()

// 创建监视函数，等价于之前的 onWindowScroll() 方法
createScrollMonitor() {
  let subscription = this.windowScrolling
    .throttleTime(200) // <-- 这是关键!
    .subscribe(
      (next) => {
        console.log("发现窗口滚动，我们已经节流");
        this.animateWhenSeen(this.$refs.wikisec as Element);
        this.animateGroupWhenSeen(this.$refs.acfsec as Element);
      }
    );
  return subscription;
};

// 在页面刚加载好时注册此行为
mounted() {
  // window.addEventListener("scroll", this.onWindowScroll);
  this.scrollSubscription = this.createScrollMonitor();
}

// 在页面卸载时删除此行为 （比如模板切换、路由切换等）
destroyed() {
  // window.removeEventListener("scroll", this.onWindowScroll);
  this.scrollSubscription.unsubscribe();

}

```

现在回到浏览器里再滚一下，我们发现情况已经好多了。

[图]

`throttleTime`的取值不能太小，也不能设的太大：太小了性能有损耗，太大了有时候视野会漏检，导致动画不播放。所以究竟多少看你感觉吧😄。


# 总结

我们看到了vue 如何实现滚动到元素位置才播放出现动画的效果。这种效果实际上分成2种情况："单个容器底下的所有元素" 和 "动画组里的所有元素"，而这两种情况都是监听浏览器的scroll事件，辅以`in-view`进行判断，通过扳动动画状态表里的开关进行动画来实现的。最后，针对scroll事件的节流需求，本文给出了利用`rxjs`来管理的建议。

# 背后原理
现代浏览器都支持`Element.getBoundingClientRect()`[方法]()，用以返回元素的尺寸，以及距视野边界的相对位置。

这个方法返回的rect对象包括top、bottom、right等属性。

B >= H && T >= 0 -------------------完全显示
0 < B < H || 0 < T < -H ------------没显示完
B <= 0 && T <= -H  -----------------完全没显示

（
其中：
B：rect.bottom，
H：window.innerHeight或者document.documentElement.clientHeight，
T：rect.top
）

[wcnexus.com](http://www.wcnexus.com) v1曾经使用类似方法判断，看到抓根宝时隐藏导航栏，看不见抓根宝时显示导航栏。

https://github.com/valorad/wcnexus.com/blob/bd4b169bd1c4935ec34a1c30b47ff6dd98bf3416/home/static/Globalsite/js/wcNexusUtil.js#L6

https://github.com/valorad/wcnexus.com/blob/bd4b169bd1c4935ec34a1c30b47ff6dd98bf3416/home/templates/home/index.html#L149

stackOverflow 上也有网友介绍了[如何使用getBoundingClientRect()](https://stackoverflow.com/questions/123999/how-to-tell-if-a-dom-element-is-visible-in-the-current-viewport)

# 其他
其实GitHub上有程序猿已经封装了vue版的in-view，不过因为它有bug，而且集成了包括animate.css在内的很多第3方库，有点小臃肿，我在项目中没有采用。

问：为何动画组不能直接用数组存放开关？像acsec: [true, true, true, ...]
答：因为vue无法检测数组成员值的变化，会导致模板不能及时更新，你会看不到动画效果。

# 参考

`Element.getBoundingClientRect()`: https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect