
## Gitlab 配置 OpenLDAP 认证
---

#### Prerequisite

基本软件环境：

- Ubuntu 14.04
- Gitlab-ce 7.14.0 # 由 omnibus packages 中的 deb 安装

#### Install and configure openldap

LDAP是轻量目录访问协议，英文全称是 Lightweight Directory Access Protocol，一般都简称为LDAP。它是基于X.500标准的，但是简单多了并且可以根据需要定制。与X.500不同，LDAP支持TCP/IP，这对访问Internet是必须的。LDAP的核心规范在RFC中都有定义，所有与LDAP相关的RFC都可以在LDAPman RFC网页中找到。 简单说来，LDAP是一个得到关于人或者资源的集中、静态数据的快速方式。 LDAP是一个用来发布目录信息到许多不同资源的协议。通常它都作为一个集中的地址本使用，不过根据组织者的需要，它可以做得更加强大。

现在市场上有关LDAP的产品已有很多，各大软件公司都在他们的产品中集成了LDAP服务，如Microsoft的ActiveDirectory、Lotus的Domino Directory、IBM的WebSphere中也集成了LDAP服务。LDAP的开源实现是OpenLDAP，它比商业产品一点也不差，而且源码开放。

OpenLDAP 是最常用的目录服务之一，它是一个由开源社区及志愿者开发和管理的一个开源项目，提供了目录服务的所有功能，包括目录搜索、身份认证、安全通道、过滤器等等。大多数的 Linux 发行版里面都带有 OpenLDAP 的安装包。OpenLDAP 服务默认使用非加密的 TCP/IP 协议来接收服务的请求，并将查询结果传回到客户端。由于大多数目录服务都是用于系统的安全认证部分比如：用户登录和身份验证，所以它也支持使用基于 SSL/TLS 的加密协议来保证数据传送的保密性和完整性。OpenLDAP 是使用 OpenSSL 来实现 SSL/TLS 加密通信。

LDAP中重要的概念:

```
	o– organization（组织-公司）
	ou – organization unit（组织单元-部门）
	c – countryName（国家）
	dc – domainComponent（域名）
	sn – suer name（真实名称）
	cn – common name（常用名称）
```

##### OpenLDAP

根据 Ubuntu 官方的文档，需要先设置本机域名 /etc/hosts:

	127.0.1.1 {host_FQDN} {hostname}

例如，将 hostname 设置为 ```openldap```

	$ sudo apt-get install slapd ldap-utils

其中，slapd 即 OpenLDAP 的 Server版本；安装完成后，可重新配置：

	$ sudo dpkg-reconfigure sladp 

sladp 有配置默认路径： ```/etc/ldap```，其中修改了 ldap.conf 中默认注释的 BASE:

```
#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.
BASE	dc=wangan,dc=org,dc=cn
#URI	ldap://ldap.example.com ldap://ldap-master.example.com:666

#SIZELIMIT	12
#TIMELIMIT	15
#DEREF		never

# TLS certificates (needed for GnuTLS)
TLS_CACERT	/etc/ssl/certs/ca-certificates.crt
```

编辑 LDIF 文件**「LDIF 文件中各行结尾处不能有空格」**：

```
dn: ou=Developer,dc=wangan,dc=org,dc=cn
objectClass: organizationalUnit
ou: Developer

dn: ou=Groups,dc=wangan,dc=org,dc=cn
objectClass: organizationalUnit
ou: Groups

dn: uid=foo,ou=Developer,dc=wangan,dc=org,dc=cn
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: foo
sn: Foo
givenName: Play
cn: FooPlay
displayName: FooPlay
uidNumber: 10000
gidNumber: 5000
userPassword: *****
gecos: Foo Play
loginShell: /bin/bash
homeDirectory: /home/foo

dn: uid=gitter,ou=Developer,dc=wangan,dc=org,dc=cn
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: gitter
sn: Gitter
givenName: lab
cn: Gitter
displayName: Gitter LAB
uidNumber: 10001
gidNumber: 5001
userPassword: 1234
gecos: GitterLab
loginShell: /bin/bash
homeDirectory: /home/gitter
```

ldapadd 命令添加用户：

	$ sudo ldapadd -x -D cn=admin,dc=wangan,dc=org,dc=cn -W -f content.ldif

如果遇 ```Invalid credentials (49)``` 错误，一般是LDIF文件中 dn 设置不正确；```Invalid credentials (21)``` 错误，可能是 LDIF 中属性值不正确「如以空格结尾」。

ldapsearch 搜索添加结果：

	$ sudo ldapsearch -x -LLL -b dc=wangan,dc=org,dc=cn dn
	$ sudo ldapsearch -x -LLL -b\
	ou=Developer,dc=wangan,dc=org,dc=cn dn

##### phpldapadmin

基于 Web 的OpenLDAP 管理「如果离线安装，依赖包较多，不推荐」

	$ sudo apt-get install phpldapadmin

因为本地上安装还安装了 Gitlab，占用了 80/8080 Web端口；需要调整 Apache2监听端口号9090： ports.conf + 000-default.conf

另，修改 /etc/phpldapadmin/config.php 中 LDAP servers 段内容：

	$servers->setValue('server','base',array('dc=wangan,dc=org,dc=cn'));
	$servers->setValue('login','bind_id','cn=admin,dc=wangan,dc=org,dc=cn');

Apache2 reload 配置后， Web 访问 phpldapadmin 页面

![phpldapadmin_login](https://github.com/chanyong-bj/docs/blob/master/pic/openldap_1.png)

在 phpldapadmin 上查看之前命令行添加的用户

![phpldapadmin_search](https://github.com/chanyong-bj/docs/blob/master/pic/phpldapadmin_1.png)

设置了两个用户 ```foo``` 和 ```gitter```：前者用于 gitlab 连接 openldap；后者用于登录测试

#### Configure gitlab

设定 /etc/gitlab/gitlab.rb 中 LDAP 的配置：

```
## For setting up LDAP
## see https://gitlab.com/gitlab-org/omnibus-gitlab/blob/629def0a7a26e7c2326566f0758d4a27857b52a3/README.md#setting-up-ldap-sign-in
## Be careful not to break the identation in the ldap_servers block. It is in
## yaml format and the spaces must be retained. Using tabs will not work.

gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
main: # 'main' is the GitLab 'provider ID' of this LDAP server
  label: 'LDAP'

  host: '{serverhost_FQDN}'
  port: 389
  uid: 'uid'
  method: 'plain'
  bind_dn: 'uid=foo,ou=Developer,dc=wangan,dc=org,dc=cn'
  password: '******'

  active_directory: false
  allow_username_or_login: true
  block_auto_created_users: false

  base: 'ou=Developer,dc=wangan,dc=org,dc=cn'
  user_filter: ''
EOS
```

* port  OpenLDAP 端口，如果是用加密的话，端口是 636
* method OpenLDAP 认证方式，plain是简单认证，还有ssl 和tls，如果是加密的话选ssl或者tls，对应端口也是636
* base：组织架构，可以精确到OU， ou=Developer,dc=wangan,dc=org,dc=cn 这里有只有Developer这个OU下面的用户能登录到gitlab验证
* user_filter 禁止某个用户登录
* bind_dn 指定连接openldap的帐号
* password 指定连接openldap的账户密码

另，需注意 allow\_username\_or\_login 配置的说明

##### Other configs

Gitlab 已有用户[以 LDAP 方式验证登录](http://doc.gitlab.com/ce/integration/ldap.html#enabling-ldap-sign-in-for-existing-gitlab-users)，关键是两个账号需要设置一致的Email

#### Refs

* [OpenLDAP Server in Ubuntu](https://help.ubuntu.com/lts/serverguide/openldap-server.html)
* [Uubntu配置LDAP](http://www.cnblogs.com/xwdreamer/p/3469951.html)
* [Gitlab Document](http://doc.gitlab.com/ce/integration/ldap.html)
* [Centos6安装gitlab+ldap认证](http://54im.com/git/centos6-install-gitlab-ldap%E8%AE%A4%E8%AF%81.html)
* [Centos安装openldap+phpldapadmin](http://54im.com/openldap/centos-6-yum-install-openldap-phpldapadmin-tls-%E5%8F%8C%E4%B8%BB%E9%85%8D%E7%BD%AE.html)
