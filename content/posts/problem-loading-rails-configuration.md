---
title: "Problem loading Rails configuration"
author: ["Yejun Su"]
date: 2023-01-14T00:00:00+08:00
tags: ["rails", "ruby"]
draft: false
---

After upgrading our application to Rails 5.2, `InvalidAuthenticityToken` errors
are found in our public APIs. The error is caused by [CSRF protection is enabled
by default since Rails 5.2](https://github.com/rails/rails/pull/29742) while it is not required in public APIs. I updated
the config to disable the default behavior, but it doesn't take effect.

```ruby
# config/initializers/new_framework_defaults_5_2.rb
Rails.application.config.action_controller.default_protect_from_forgery = false
```


## The problem {#the-problem}

According to the [source code](https://github.com/rails/rails/blob/404ad9e8acf8ab45ae2314050131a00e57e63b40/actionpack/lib/action_controller/railtie.rb#L75-L81), the config is used to toggle CSRF protection after
`ActionController::Base` is loaded:

```ruby { hl_lines=["3"] }
initializer "action_controller.request_forgery_protection" do |app|
  ActiveSupport.on_load(:action_controller_base) do
    puts "default_protect_from_forgery: #{app.config.action_controller.default_protect_from_forgery}"

    if app.config.action_controller.default_protect_from_forgery
      protect_from_forgery with: :exception
    end
  end
end
```

I use [this gist](https://gist.github.com/goofansu/8ab92ba07a9309ac0bbab1089d4ffbe1) to debug how configurations are loaded:

```plain { hl_lines=["4"] }
before_configuration
application.rb loaded
before_initialize
default_protect_from_forgery is true, expected: false
config/initializers loaded
ActiveSupport.on_load(:before_initialize) runs at the end of before_initialize
after_initialize
default_protect_from_forgery is false, expected: false
ActiveSupport.on_load(:after_initialize) runs at the end of after_initialize
```

The highlighted line shows the value of `default_protect_from_forgery` is `true`
while it should be `false`. So the problem is `ActionController::Base` is loaded
before loading `config/initializers`.


## Investigation {#investigation}

I commented all gems except the rails gem, then uncommented them one by one and
debug configuration loading with rails c to see the prints like above, finally
found it is caused by the [wechat](https://github.com/Eric-Guo/wechat) gem:

-   <https://github.com/Eric-Guo/wechat/blob/v0.12.2/lib/wechat.rb#L10>
-   <https://github.com/Eric-Guo/wechat/blob/v0.12.2/lib/action_controller/wechat_responder.rb#L68>


## Solution {#solution}

The problem can be fixed if:

-   Gems load files with Zeitwerk (e.g. <https://github.com/Eric-Guo/wechat/pull/293>).
-   gems load files in after_initialize with `Railtie`.

I created a repo for showing the problem, see the following commits for details:

-   [gem with classic mode loads class unexpected](https://github.com/goofansu/rails-config-demo/commit/2e7787010609bdf6c045f2e06b3f691012676f27)
-   [gem with zeitwerk mode lazy load classes](https://github.com/goofansu/rails-config-demo/commit/fb6e00880c80a00a19bf91b571a17c228b53a992)
