将django项目部署到nginx
===

###简介
这个文档是将django的项目移植到nginx上面，网上总结的也很多。  
但是为什么要做这个工作呢？  
1. django只是一个快速搭建web的框架，具体部署还得放到HTTP server上面  
2. nginx网传性能很好，而且几家大公司也开始用这个，因此最近它比apache的httpserver要火

虽然django项目部署到nginx有很多方法，这里单单使用uWSGI。  

对于static文件（html,css,image等）可以直接访问文件系统将内容显示到httpserver中，但是对于django的项目却不行，server需要一些东西来跑django的应用，通过请求反馈响应。这就需要使用
[WSGI](http://wsgi.org/)（Web Server Gateway Interface），它是一种python的协议，解释web server如何和web应用（如django应用）沟通。

uWSGI是WSGI协议的实现。  

最终我们要实现的是如下结构：

	the web client <-> the web server <-> the socket <-> uwsgi <-> Django

###具体步骤
#####假设你已经知道
1. 这里假设已经会使用django创建应用
2. 并且已经基本熟悉nginx的配置
3. 熟悉pip安装python库

#####安装uwsgi

	$ sudo pip install uwsgi
	
#####配置uwsgi随系统启动
你也可以选择不随系统启动，然后需要使用时启动

	# mysite.wsgi  是django应用中的wsgi
	uwsgi --http :8000  --module mysite.wsgi
	
随系统启动（使用[upstart](http://www.linuxidc.com/Linux/2012-07/65001.htm)方式）

添加文件/etc/init/uwsgi.conf  
$ sudo service uwsgi [start | stop | restart] 管理

	description "uWSGI"
	start on runlevel [2345]
	stop on runlevel [06]
 
	respawn
 
	exec uwsgi --master --processes 4 --die-on-term --socket /tmp/uwsgi.sock \
	--chmod-socket 666 --vhost --logto /var/log/  uwsgi.log \
	--plugins python

#####配置nginx
demo.conf 文件放入conf.d中，然后将sites-enable中default先删掉
	
	#demo.conf
	upstream django {
    	server unix:///path/to/your/mysite/mysite.sock; # for a file socket
    	# server 127.0.0.1:8001; # for a web port socket (we'll use this first)
	}

	server {
    	listen          80;
    	server_name     $hostname;
    	
    	location / {
        	include         uwsgi_params;
        	uwsgi_pass 		unix:/tmp/uwsgi.sock;
        	uwsgi_param UWSGI_CHDIR /var/www/<app-name>/project;
        	uwsgi_param UWSGI_MODULE <project-name>.wsgi:application;
    	}      
	}

#####配置static文件
前面已经基本的业务都可以实现，但是还不能显示css等静态文件效果  
1. admin的static文件
在django项目中的settings文件中将STATIC_ROOT指向你的static绝对路径（如：/var/www/project/app/static）  

	$python manage.py collectstatic

2.在demo.conf文件添加static指向

	#demo.conf
	upstream django {
    	server unix:///path/to/your/mysite/mysite.sock; # for a file socket
    	# server 127.0.0.1:8001; # for a web port socket (we'll use this first)
	}
	location /static {
        alias /var/www/<app-name>/static;
    }
	server {
    	listen          80;
    	server_name     $hostname;
    	
    	location / {
        	include         uwsgi_params;
        	uwsgi_pass 		unix:/tmp/uwsgi.sock;
        	uwsgi_param UWSGI_CHDIR /var/www/<app-name>/project;
        	uwsgi_param UWSGI_MODULE <project-name>.wsgi:application;
    	}      
	}



---
以上部分已经完成了全部的部署，可以通过http://localhost查看了。  
下面是一些总结

###权限


#####web项目中，当前用户可以有权限编辑项目文件
因为一般我们把项目放到/var/www之类的文件中  
但是这个www文件root的，而且对组外只有r/x的权限
	
	$ ll /var/www
	drwxr-xr-x  2 root root   ./

解决办法，将文件所有权给当前用户，就可以在创建文件等。

	$ sudo mkdir myproject
	$ sudo chown -R $USER:$USER myproject

#####对于nginx程序创建的文件，当前用户该如何读写
说的简单点，就是放到nginx跑的web程序自身创建的文件，当前用户如何读写，因为nginx是以root权限启动daemon进程的。以/etc/nginx/nginx.conf中的user启动worker process。
	
暂时还没想好。。。只能通过别的方法绕过它






###参考
1. [Setting up Django and your web server with uWSGI and nginx](https://uwsgi.readthedocs.org/en/latest/tutorials/Django_and_nginx.html)
2. [How to Setup a Linux, Nginx, uWSGI, Python, Django Server](http://grokcode.com/784/)
3. [upstart](http://www.linuxidc.com/Linux/2012-07/65001.htm)
