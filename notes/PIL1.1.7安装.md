## PIL 1.1.7 安装
----
虽然 PIL 已经被 Pillow 替代，但 MVTP_web 依赖 django-simple-captcha；后者又依赖 PIL 1.1.7 或 Pillow 2.4+ 的版本。
> 可能直接 安装 Pillow 来得更简单，但有声音说 django-simple-captcha 支持存在问题。

> 问题来了，无法直接 pip install PIL==1.1.7；另，django-simple-captcha 提示说需要 freetype 编译支持。

> 参考 http://codeinthehole.com/writing/how-to-install-pil-on-64-bit-ubuntu-1204/

----

1. 安装依赖
```
	apt-get install python-dev libjpeg-dev libjpeg8-dev libpng3 libfreetype6-dev zlib1g-dev
```

2. 创建链接
```
	ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
	ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/
	ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/
	ln -s /usr/include/freetype2 /usr/include/freetype
```

3. 下载 PIL 源码，解压，编译 http://www.pythonware.com/products/pil/
```
	python setup.py build_ext -i 
```

4. 测试
```python selftest.py```
	
5. 安装 
```python setup.py install```
