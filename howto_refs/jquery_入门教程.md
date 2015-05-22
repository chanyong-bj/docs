
## jQuery 入门教程

[参考](http://www.365mini.com/page/jquery-quickstart.htm "jQuery入门")

jQuery库中定义了一个jQuery()方法：

	方法调用后返回一个 jQuery实例对象，该对象中包含了匹配的一个或多个DOM元素；对 jQuery 对象执行相关的操作即可实现对匹配 DOM 元素的操作


#### jQuery 选取 DOM 元素

在原生的 JS 中操作 DOM 元素，需要先通过 getElementById() / getElementsByTagName() 等方法获取元素，再对这些元素进行操作。

jQuery 同样需要先选取对应的 DOM 元素，然后再进行操作：

	$("#uid"); // 选取id属性为"uid"的单个元素
	$("p"); // 选取所有的p元素
	$(".test"); // 选择所有带有CSS类名"test"的元素
	$("[name=books]"); // 选择所有name属性为"books"的元素

jQuery 获取元素通过类似 CSS 选择器的字符串来匹配对应的元素。几乎所有的 CSS 选择器都可以当做 jQuery 的选择器来使用，并且支持多外选择器任意组合。

	$("p#uid"); // 选择id属性为"uid"的p元素	
	$("div.foo"); // 选择所有带有CSS类名"foo"的div元素
	$(".foo.bar"); // 选择所有同时带有CSS类名"foo"和"bar"的元素
	$("input[name=books][id]"); // 选择所有name属性为"books"并且具备id属性的元素

jQuery 特有选择器

	$(":checkbox") // 选取所有的 checkbox 元素
	$(":text") // 选取所有的 type 为 text  的 input 元素
	$(":password") // 选取所有的 type 为 password 的 input 元素
	$(":checked") // 选取所有选中的 radio checkbox option 元素
	$(":selected") // 选取所有的选中的 option 元素
	$(":input") // 选取所有的表单控件，包括 input texterea select button 元素

参考：[jQeury选择器](http://www.365mini.com/page/tag/jquery-all-selectors)

此外，jQuery 还支持将一个 DOM 元素或一段 HTML 字符串转换成 jQuery 对象。


#### jQuery 元素筛选

参考：[jQuery的文档筛选方法]（http://www.365mini.com/page/tag/jquery-filter-methods）


### jQuery DOM 操作

jQuery 对象封装了指定的 DOM 元素，两个基本的操作原则：

	1. Get and Set in One
		
		操作 DOM 的接口方法，通常是『读写一体的』，即一个方法名可用于读取或设置操作。调用时，如果不有传入参数值，则表示获取操作；如果传入参数则表示设置，为 DOM 元素设置指定的属性值。
				
	2. Get First and Set All
		
		当前的 jQuery 对象匹配或封装了多个 DOM 元素，如果调用 jQuery 对象的方法来读取数据，则只会获取第一个匹配元素的数据；如果调用 jQuery 对象的方法来设置元素属性值，则会对所有匹配的元素都进行设置操作。
		
jQuery在匹配不到指定 DOM 元素时将返回一个空的 jQuery 对象。对空 jQuery 对象的操作不会抛出异常；即，获取数据，返回 null 或 undefined；设置值，则忽略设置操作，并返回该空对象本身；筛选元素，返回一个新的空对象。		

#### 文档元素属性和内容操作


#### 事件处理


#### 对象遍历操作

jQuery中常用的遍历函数：
	
	jQuery.each() // 遍历数组元素或对象属性
	jQuery.map() // 遍历数组或对象，并将每次遍历时执行的遍历函数的返回值封装为数组返回
	jQuery.grep() // 遍历数组元素，根据判定函数过滤数组元素




#### Ajax 请求


参考:[jQuery Ajax方法](http://www.365mini.com/page/tag/jquery-ajax-methods)


#### 扩展 jQuery对象属性或方法

通过 jQuery。extend() 和 jQuery.fn.extend() 方法，允许分别为全局的 jQuery对象扩展自定义的属性和方法。




