---
title: android 阶段学习1
date: 2021-1-21 20:19:26
categories: Android
top_img: https://cos-study.jinlinle.com/nova/1200px-android-logo-2019svg-16112786522ZL1D.png
cover: https://cos-study.jinlinle.com/nova/1200px-android-logo-2019svg-16112786522ZL1D.png
tags:
  - Android
---

# android 阶段学习 1

## 布局

三大常用布局：

- LinearLayout，线性布局
- RelativeLayout，相对布局
- ConstraintLayout，约束布局

### LinearLayout

其中部分概念有点像 ReactNative 里面的 flex 布局，比如权重，排列方向，但是没有 ReactNative 里面的 flex 舒服，因为少了排列适配属性（Align Items），所以它似乎比较好做一些，小部件的排列。

```xml
android:orientation="horizontal"
```

该属性控制子元素排列方向

```xml
android:layout_weight="1"
```

这个属性控制子属性所占百分比，很像 RN 里面的 flex 属性。

orientation 控制子属性横着的还是竖着的，layout_weight 控制子属性占用空间的百分比

### RelativeLayout

这个相对布局一点也不像 HTML 里面的相对布局，根本不一样

这种布局，可以控制子组件排在哪里，然后其他子属性可以在指定的组件的任意方向。

如果子组件想在父容器的中心，layout_centerInParent 设置成 true 就可以。

- layout_centerInParent，控制元素在父组件中心
- centerVertical，控制元素是竖着的，而且是竖着的中心
- layout_centerHorizontal，控制元素在横着的中心

然后还有 toRightOf / toLeftOf / above / below

指定子元素，在参考物的上面还是下面，左边还是右边

这种的，可以比较粗的实现布局，然后再通过代码控制 padding 或者 margin，达到对应的 UI 效果

### ConstraintLayout

这种布局，有点像是以上两种的结合体，拖拽+辅助线就挺好使

```xml
<TextView
        android:id="@+id/TextView1"
        ...
        android:text="TextView1" />

    <TextView
        android:id="@+id/TextView2"
        ...
        app:layout_constraintLeft_toRightOf="@+id/TextView1" />

    <TextView
        android:id="@+id/TextView3"
        ...
        app:layout_constraintTop_toBottomOf="@+id/TextView1" />
```

TextView2 在 1 的左边，这叫 Left_toRightOf，就是我的左边在你的右边，所以我在你的左边

然后 TextView3 在 1 的下面，这叫 Top_toBottomOf，就是我的上面在你的下面，所以我在你的下面

常用的属性有这些：

```
layout_constraintLeft_toLeftOf，我的左边在你的左边
layout_constraintLeft_toRightOf，我的左边在你的右边
layout_constraintRight_toLeftOf，我的右边在你的左边
layout_constraintRight_toRightOf，我的右边在你的右边
layout_constraintTop_toTopOf，我的上面在你的上面
layout_constraintTop_toBottomOf，我的上面在你的下面
layout_constraintBottom_toTopOf，我的下面在的上面
layout_constraintBottom_toBottomOf，我的下面在你的下面
layout_constraintBaseline_toBaselineOf，我的中心线和你对齐
layout_constraintStart_toEndOf，我的开始在你的收尾
layout_constraintStart_toStartOf，我的开始在你的开始
layout_constraintEnd_toStartOf，我的结尾在你的开始
layout_constraintEnd_toEndOf，我的结尾在你的结尾
```

## 资源引用

就是在 android 里面最好不要硬编码，虽然这很爽，但 android studio 能烦死你，一直给你警告，给你报错，让你惶惶不能终日。

然后就是在 xml 里面定义各种属性

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="purple_200">#FFBB86FC</color>
    <color name="purple_500">#FF6200EE</color>
    <color name="purple_700">#FF3700B3</color>
    <color name="teal_200">#FF03DAC5</color>
    <color name="teal_700">#FF018786</color>
    <color name="black">#FF000000</color>
    <color name="white">#FFFFFFFF</color>
</resources>
```

就像这样，然后引用的时候：`app:backgroundTint="@color/design_default_color_error"`

然后一堆巴拉巴拉这样的属性，你按规格引用就行了。

## 基础组件的使用

慢慢用吧，用不完的，这东西不能强求，要用的时候翻翻找找，就找到了，
