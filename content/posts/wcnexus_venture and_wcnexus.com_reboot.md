---
title: "wcnexus Venture and wcnexus.com reboot"
date: 2017-12-09T11:00:00+08:00
draft: false
featured_image : "images/wcnexus_venture and_wcnexus.com_reboot/wcnexus.png"
tags: ["冒泡"]
isCJKLanguage: true
---

我的个人网站wcnexus之前一直有个遗憾，就是venture（博客）部分从v1到v2都一直没有完成。考虑到我的小破网站的访问量、我自身的精力等因素，我最后决定用hugo来搭建。


hugo是基于Go语言编写的基于Markdown生成静态html博客的程序，如果要我说上手难度，虽然教程少，官方文档也写得烂，但是出人意料得简单。当然你可能会认为隔壁hexo主题又多，教程又多，用的人也多，特别是国人也多，又是基于node.js，是不是更简单。对，就是更简单，但是我看到网上也有人认为：[感觉要么环境麻烦，要么生成静态页面步骤繁琐以及生成缓慢][1]。Hugo也还好，只需要`git submodule add`一个主题就可以开始写博客了。


但是很遗憾，目前没有一个主题和wcnexus.com搭，所以，就只有劳烦小马甲们再自己写一个主题，这就是小马甲wcxaaa趁着这周比较闲赶紧做的事情。写主题就比较麻烦了，就像我刚才说，官方文档写得超烂，再加上我不会go语言，怎么办我是不是不行？并没有，我没学过go但是我看过python（貌似没关系。。。），没接触过hugo主题但我接触过wordpress和django，再加上[官方那么多个主题][2]供我参照，就慢慢摸索写出来了。


接下来的时间，我的想法是把wcnexus.com也重新做一下。现在的wcnexus.com部署在一台渣渣vps上，那个vps我一访问就爆炸，网页都打不开。。。没办法，咱穷。。。


- 前端开发框架不要angular-cli了，太吓人了！
- 主页面重新设计一下，整的更material一点。
- 不要主题切换功能了。
- 后台由express换成koa
- 登录模块可能要换成自己的。

还有啥我想到再写吧。

[1]:http://www.jianshu.com/p/f1b02e00f206
[2]:https://themes.gohugo.io/