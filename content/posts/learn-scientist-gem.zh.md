---
title: "初识 scientist gem"
author: ["Yejun Su"]
date: 2022-03-31T00:00:00+08:00
tags: ["ruby", "scientist"]
draft: false
---

最近项目中的一个功能有性能问题，改进方案很简单，就是用缓存代替实时计算，但是缓存需要及时更新，不能返回错误的结果。
这个过程需要用生产环境的数据来检验，但是又不能破坏现有的功能，正巧前几天读了 [Changing Critical Code Paths With Scientist](https://world.hey.com/jorge/changing-critical-code-paths-with-scientist-a3becb84), 发现文中提到的 scientist gem 就是解决这个问题的。

> 🔬 A Ruby library for carefully refactoring critical paths.
>
> -- <https://github.com/github/scientist>

这个项目的命名很形象，我们开发者就好比是科学家 (scientist)，要改进现有的方案，一个稳妥地方法是进行对照实验 (controlled experiment)，把现有方案设为对照组 (control)，新方案设为实验组 (candidate)，在同一环境、同一时间进行实验，减少不确定的因素带来的影响。

下面言归正传，让我们看一下如何使用 scientist。

首先，引入 `Science` ，它提供了一些 DSL，使用 `science` 块可以很方便地定义实验：

```ruby
class Query
  include Science

  def fetch_data
    science 'fetch-data' do |experiment|
      experiment.use { ... } # control
      experiment.try { ... } # candidate 1
      experiment.try { ... } # candidate 2
    end
  end
end
```

其次，实现 `Scientist::Experiment` ，我把它放在了项目的 `config/initializers/scientist.rb` ，

```ruby
require "scientist/experiment"

class ScientistExperiment
  include Scientist::Experiment

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def enabled?
    true
  end

  def raised(operation, error)
    super
  end

  def publish(result)
    puts "science.#{name}.mismatched" if result.matched?
    puts result.control.duration
    puts result.candidates.first.duration
    puts result.observations.map(&:name)
  end
end

ScientistExperiment.raise_on_mismatches = true if Rails.env.test?
```

解释一下几个方法调用：

-   `enabled?` 返回 true 表示启用实验；
-   `publish` 表示发布实验结果，在这里一般是把结果输出到可以查看的地方，比如日志或错误监控系统；
-   `ScientistExperiment.raise_on_mismatches = true` 表示如果实验结果不一致，就抛出异常，在测试环境中开启这项可以及早发现问题。

设置完以后启动 Rails 服务，就可以实验了。这种方式适用于在生产环境改进算法、性能、重构，不用担心带来破坏性的问题。
当然，scientist 也有其局限性：如果实验结果无法比较，或者不能仅通过比较结果来判断方案的可行性，那么它可能就不适用。
不过，使用 scientist 使我能更平静地改进代码，我想这就足够了。
