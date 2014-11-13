Web Clipboard
===

### 2014-11-13 [Django Session contrib.user & authentication]

#### Djanog user 用户认证与授权 (auth/auth)
* auth/auth 依赖与 session framework，需要同时配置 session

    - 在 INSTALL_APPS 中添加 django.contrib.auth
    
    - MIDDLEWARE_CLASSES 中 SessionMiddleware 后设置 django.cotrib.auth.middleware.AuthenticationMiddleware
  
* 在 View 中使用 user 对象
    request.user 是对 auth.User 实例引用（如果未登录，则是 AnonymousUser 实例）
      - 由 auth middleware 设置
      - user 对象除拥有自身属性和方法外，还具有 groups 和 permissions 多对多字段
      
      - django.contrib.auth 分别提供了 authenticate() / login() / logout() 3个函数

      - django.contrib.auth.decorators login_required / permission_required 装饰符
    
#### MVTP TODO 

1. 查看 用户密码设置代码 

### 2014-11-13 [Django Caching framework]
Django comes with a robust cache system that lets you save dynamic pages so they don’t have to be calculated for each request. 
* Django 支持不同粒度的cache设置：单个view输出、部分计算结果(例如，部分的template内容)或整个site
    - settings.py 中设置 CACHE_BACKEND
    
    - Django 提供了低层次 cache 接口，以实现对PY对象的 caching
        * django.core.cache.cache.get()/set()/add()









