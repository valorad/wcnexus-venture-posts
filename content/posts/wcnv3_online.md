---
title: "wcnexus.com v3 上线了 + Webhook"
date: 2017-12-27T15:27:14+08:00
draft: false
tags: ["冒泡", "技术"]
isCJKLanguage: true
---

wcnexus.com v3 上线了

Yeah~

博客还有一件事没做完，就是把Webhook打开。目前小马甲团队已经写出来了一个简易的[Webhook](https://github.com/xmj-alliance/webhook-koa)，是基于node.js的koa框架的，可以作为Docker容器里使用。但是我还需要把Github链上去。

既然是博(shui)客(tie)，顺便说一下Webhook吧。

Webhook是啥？[Webhook][1]就是网站开发的时候，为了改版或增强网页或网络app的展现方式所使用的一种手段。Github这边也有Webhook，通俗来说就是相当与一个事件触发器。比如说，仓库里面push了代码，Github触发了[Push事件][2]，如果我们用个后台监听这个事件，就可以执行相应的指令，完成一些自动化工作。

跟我有什么关系？当然有。wcnexus的venture页面事实上是由hugo生成的一系列静态页面，不是动态的，并没有数据库，抱歉让你们失望了（🙂）。新博客展示到你面前的流程是这样的：

- 本地 `git clone`博客仓库
- 瞎写一通，保存，`git commit`，`git push`
- 服务器上 `git pull`
- 服务器上 `hugo`一下生成新的静态文件

然后你访问的时候nginx就自动serve这些静态资源，你就看到了这些博客。

但是我每写一篇博客都要去服务器上操作就太累了。还好我不是大水笔，不像正经点的博主天天都水贴，那样每天都登录服务器，ssh输密码，`cd`到那个目录， `git pull` ，`hugo`一下，累不累？

这时候，Webhook就闪亮登场了。新博客展示到你面前的流程变成了这样：

- 本地 `git clone`博客仓库
- 再水一贴，保存，`git commit`，`git push`，Github触发push事件
- 服务器监听到Github的push事件，自动执行`git pull`和`hugo`一下

这样我就方便多了，不用自己去亲自做那些操作，就有更多事件给你们发技术(shui)贴了:)

[1]:https://en.wikipedia.org/wiki/Webhook
[2]:https://developer.github.com/v3/activity/events/types/#pushevent
