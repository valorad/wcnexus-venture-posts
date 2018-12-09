---
title: "老滚5装备乱入辐射4（小白版）"
date: 2018-12-08T23:44:01+08:00
draft: false
featured_image : "images/skyrimArmor2Fo4/cover.jpg"
tags: ["模型", "3dsmax", "mod", "上古卷轴", "辐射"]
isCJKLanguage: true
---

相信有很多玩家想让天际乱入辐射4，来一次全新的体验。

目前有几个这样的mod，例如天际动力甲mod[TES-51 Power Armor -Skyrim Inspired-](https://www.nexusmods.com/fallout4/mods/17956)，让人眼前一亮。但是这样的mod很少，着实差强人意。

另一方面，在[N网](https://www.nexusmods.com)上，天际的mod数量有辐射4的3倍之多，但是并不是所有的mod作者都会将自己的装备mod移植到辐射4中。

但是装备就在手边，我们能不能自己动手，来一把乱入呢？

本教程将介绍如何将装备模型从天际移植到辐射4里，涉及3dsmax和bodySlide。这是一个小白教程，无需任何3dsMax基础，因为我也是小白，我也不会3dsmax :) 我们会使用`BodySlide`帮助我们绑骨骼。

**声明：**

- 在未经允许的情况下，将原版装备或其他作者的mod移植到辐射4然后上传到N网是违反用户守则的，我们可以私下交流，但是请不要侵犯他人的著作权。

- 教程中的“天际”是[《上古卷轴5：天际 特别版》](https://store.steampowered.com/app/489830/The_Elder_Scrolls_V_Skyrim_Special_Edition/)，您也可以使用[《上古卷轴5：天际 传奇版》](https://store.steampowered.com/app/72850/)，流程基本一致，记得在导入时选择正确的游戏版本。

- (封面图文无关)

## 所需软件

[BAE - Bethesda Archive Extractor](https://www.nexusmods.com/fallout4/mods/78)

3dsmax 及其配套的[Nif Plugin](https://www.nexusmods.com/skyrim/mods/84041/)

[3dsMax_Skyrim_To_Fallout4_LoosePoseConvertAnimation](https://www.nexusmods.com/fallout4/mods/11070)

辐射4版的[BodySlide and Outfit Studio](https://www.nexusmods.com/fallout4/mods/25/)

[辐射Material编辑器](https://www.nexusmods.com/fallout4/mods/3635)

(可选) [NifSkope](https://github.com/niftools/nifskope/releases)

(可选) 妹子身形：[Caliente's Beautiful Bodies Enhancer -CBBE-](https://www.nexusmods.com/fallout4/mods/15)
猛男身形：[Super Hero Bodies (Enhanced Vanilla Bodies Conversion)](https://www.nexusmods.com/fallout4/mods/10360)

## 开始

### 导出天际的装备

前往天际的`Data`目录，使用BAE解压`Skyrim - Meshes0.bsa`、`Skyrim - Meshes1.bsa`中您所需要的模型。

（记得还要解压男性骨骼`\meshes\actors\character\character assets\skeleton.nif`或女性骨骼`\meshes\actors\character\character assets female\skeleton_female.nif`）

同样解压`Skyrim - Textures0.bsa`一直到`Skyrim - Textures9.bsa`中模型所涉及的材质。

目标目录随意，假设目标目录为`tes5-sse-modding`

![Demo](https://i.imgur.com/BusWpCu.png)

打开3dsmax，左上角菜单`File -> Import -> Import`，选择刚刚解压的骨骼文件。记得把“Import Skeleton”勾上。

![Demo](https://i.imgur.com/pLWmZCM.png)

成功导入后，将图中的所有蓝色球球和绿色矩形框删掉。（警告一波，不要Ctrl+Q一起删，程序会爆炸）

![Demo](https://i.imgur.com/Pu1OP28.png)

![Demo](https://i.imgur.com/Pdiccdc.png)

接下来，导入您想转换的装备。记得这一次，把“Import Skeleton”勾去掉。

![Demo](https://i.imgur.com/6DS2xzZ.png)

我们这里以天际里男性版的龙骨护甲为例介绍。

导入

`tes5-sse-modding\meshes\armor\dragonbone\dragonbonearmorm_1.nif`

`tes5-sse-modding\meshes\armor\dragonbone\dragonboneboots_1.nif`（导入后删掉DragonboneHelmet_ORC这个部件）

`tes5-sse-modding\meshes\armor\dragonbone\dragonbonegauntlets_1.nif`

`tes5-sse-modding\meshes\armor\dragonbone\dragonbonehelmet_1.nif`

![Demo](https://i.imgur.com/RmofQug.png)

完成后`Ctrl + A`选择所有的部件，菜单`Animation -> Load Animation`，选择`3dsMax_Skyrim_To_Fallout4_LoosePoseConvertAnimation`中的xaf文件。

底部的动画帧序列里，将滑块滑至中间范围，这时候模型动作发生了变化，变到了辐射4的位置。

![Demo](https://i.imgur.com/R2UgMMi.png)

这时候取消选择全部部件，然后删除`MaleArmorBody`这个部件

接下来选中所有装备（不包括骨骼），例如我们这里的`DragonboneArmor`, `DragonboneGauntlets`和`DragonboneHELMET`，在视图中右键，`Covert To: -> Convert To Editable Mesh`，这样模型就固定下来，不会改回去了。

![Demo](https://i.imgur.com/IBwTRCo.png)

菜单`File -> Export -> Export`导出这个模型`DragonboneArmor.nif`，格式选择`.nif`

![Demo](https://i.imgur.com/G0kVK2j.png)

### 导入装备到辐射4

创建一个新目录（例如`fo4-modding`）

前往辐射4的`Data`目录，使用BAE，在`Fallout4 - Materials.ba2`中提取任意一种Material（例如`Whatever.BGSM`），

使用BAE解压身形 （在`Fallout4 - Meshes.ba2`中）以及材质（在`Fallout4 - Textures1.ba2`中），到您刚创建的目录

**（或）**

使用一种身形，Mod安装的时候已经解压到了`Data`目录（`需求`章节中有推荐的妹子和猛男的身形）

将模型所需的材质拷贝至`fo4-modding`中

打开BodySlide，选择右下角`Outfit Studio`

![Demo](https://i.imgur.com/CNhwkEP.png)

菜单 `File -> New Project`
![Demo](https://i.imgur.com/xxVlLPu.png)

选择 `From File`， 选择上一步中的身形文件。（原版的或mod）例如我们这里使用的是MaleBody.nif（`fo4-modding\Meshes\Actors\Character\CharacterAssets\MaleBody.nif`），点`Next`

输入模型名称，`Outfit/Mesh`选择`From File`，再浏览到刚刚导出的`DragonboneArmor.nif`。

![Demo](https://i.imgur.com/L2lgYgo.png)

刚刚导入进Outfit Studio时，模型可能是飘在身形上面的，这时候你要先把视角拉远才看得到。

在右上方的部件列表里，选中除了绿色的所有部件，右键`Move`，对话框中在Z轴右边的数值框内填入`-120`，装备就掉下来了。

![Demo](https://i.imgur.com/tlj7jDG.png)

您可能还要适当调整Y轴的位移，让装备基本贴合到身形上。

在辐射4里，贴身装备就只分为头和身，所以我建议这个地方分开来做，以简化绑骨骼的难度。我们暂时将删除头盔删除。

![Demo](https://i.imgur.com/LXIrdeb.png)

现在我们的装备很不合身，辐射4里的男人长得比老滚的胖（or壮，whatever）。接下来我们用BodySlide的OutfitStudio提供的工具打磨装备。我们主要用到模型局部升高和局部降低这两个小工具。在右上角的列表里，你只能一次选择一个装备进行打磨。

![Demo](https://i.imgur.com/webZ4Y4.png)

![Demo](https://i.imgur.com/BcjDoRp.png)

打磨装备后，我们开始绑定骨骼。选择右上角除了绿色的所有部件，右键`Copy Bone Weight`，调整合适的`Search Radius`和 `Max Vertex targets`。一般默认的值就可以，但是我这边实测默认值会发现装备会变形，骨骼会绑定得很惊奇，所以我选择最大值。

在右上角的列表中对一个部件右键选择`Properties`，你看到上面有一个Material输入框是空的。辐射4还需要我们提供一个`Material`（.BGSM）文件，才能让装备的材质在游戏中正常显示。

这种文件可以在`Fallout4 - Materials.ba2`中提取。复制您最开始提取的文件（例如`Whatever.BGSM`）到`fo4-modding\Materials\（...装备名）`（例如`fo4-modding\Materials\armor\dragonbone\dragonbonearmor.BGSM`）。每一种材质需要一个material文件。例如我这里有3个部件，3种材质，所以要3个material文件。

装备的材质在导入的时候就已经附上了。右下角有一个`Textures...`按钮，点击它，弹出一个材质对话框，放在一边备用

![Demo](https://i.imgur.com/vrJjr5v.png)

使用`辐射Material编辑器`打开，游戏选择`FO4`，切换到`Material`标签，对照之前的材质对话框把相应的信息填写进去。填完记得保存。

![Demo](https://i.imgur.com/nf1YWEp.png)

如法炮制，完成剩下的部件的Material文件填写工作。

完成之后，回到Outfit Studio，将每个部件对应的Material信息填进刚才空着的输入框。 

保存这个项目（`File -> Save Project`）。

接着关闭Outfit Studio，在BodySlide控制界面，第一个下拉框选择刚才的装备项目名称，然后点击下面那个Build按钮，生成这个装备。
（原版身形的话Preset可以不用填。如果你使用了提到的推荐身形的话，记得要选择正确的对应身形）

![Demo](https://i.imgur.com/jQgRfok.png)

大功告成！

（可选）您现在可以用`NifSkope`打开刚才这个项目，检查有无严重的变形问题。如果你发现最后的骨骼绑定错位，装备变形，或者进游戏人物走路时装备晃动很奇怪，你可以尝试重新调整`Copy Bone Weight`里面的`Search Radius`和 `Max Vertex targets`值。如果发现无论怎么调整都不合适，建议你删掉一直错误的那部分，回到3dsmax里重新导出那部分装备，一件一件地导出，一件一件地打磨，一件一件地“Copy Bone Weight”，最后拼在一起（把nif拖进列表即可）。

![Demo](https://i.imgur.com/6UyTlD7.png)

同样的方法，我们顺便把头盔也做了吧。

头盔的原版头形文件我选的是`BaseMaleHead.nif`。在打磨好装备后要删掉头形部分

![Demo](https://i.imgur.com/qmQf7Vn.png)

好了，我们现在用CK做个mod，接下来是见证奇迹的时刻！

![Demo](https://i.imgur.com/gCvdPCR.jpg)

OOOOOOOOh yeah！~ It worked! 看着还不错！挺合身。

![Demo](https://i.imgur.com/rN5uJBQ.jpg)

不过，这样导入的装备不能算完美，在某些动作下人物的肉还是会“爆”出来，后期还需要对此进一步地打磨。

当然如果想完美解决这个问题，

第一，请耐心学习3dsmax，自己绑骨骼。

第二，

[Creation Club](https://creationclub.bethesda.net/en) 欢迎您！【奸笑

## 总结

本教程介绍了通过3dsmax和bodyslide，如何简单地将天际的装备导入到辐射4中。方法很小白，上手很简单，但是有一定的局限性。

## 参考

[1] Nexus Mods :: Fallout 4. (2018). 3dsMax_Skyrim_To_Fallout4_LoosePoseConvertAnimation. [online] Available at: https://www.nexusmods.com/fallout4/mods/11070 [Accessed 9 Dec. 2018].

[2] Nexus Mods :: Fallout 4. (2018). SKYRIM to FALLOUT 4 Armor Conversion Tutorial. [online] Available at: https://www.nexusmods.com/fallout4/mods/21111/?tab=description [Accessed 9 Dec. 2018].

