
#### git 快照基本操作

##### `git diff`

	- `git diff` # 查看尚未缓存的修改，即比较最近一次提交后版本库与当前**尚未缓存**的所有修改 
	- `git diff <file>`  # 对比文件`<file>`工作区与版本库差异
	- `git diff --cached` 和 `git diff --staged` # 对比缓存区与版本库差异 
	- `git diff HEAD` # 对比缓存区与工作区相对于版本库的所有修改

##### `git reset HEAD -- file`

**`unstage`**功能，取消文件 file 的缓存「工作区文件 file 在命令前后不会更改，因为此时缓存与工作区内容是一致的」

* 实际的操作是将该文件在缓存区中的校验和重置为最近一次提交中的值

##### `git checkout -- file`

**撤销 file 在工作区的修改**，或者是**丢弃file在当前工作区中的修改**，恢复至最近一次 `git add` 或 `git commit`后的状态

* 用版本库里的版本替换工作区的版本，无论工作区中对文件的操作是修改还是删除

##### `git rm <file>`

默认情况，将`<file>`从缓存区和工作区完全删除，即从当前跟踪列表中移除文件`<file>`

* `git rm --cached <file>` 仅在缓存区中删除文件，保留工作区内容，不再跟踪

---

#### git 分支基本概念

Git 版本库中通过类似指针的`分支名`以及 HEAD，管理版本库分支。master 初始分支，会随着每一个次的 `commit` 延时间线推进。

![enter image description here](http://www.liaoxuefeng.com/files/attachments/0013849087937492135fbf4bbd24dfcbc18349a8a59d36d000/0)

如果 `git checkout -b dev` 创建并切换新的分支，HEAD则会被调整指向当前的分支dev 

![enter image description here](http://www.liaoxuefeng.com/files/attachments/001384908811773187a597e2d844eefb11f5cf5d56135ca000/0)

随后在`dev`分支上的 `git commit` 都只会使 dev 指向移动，而 master 指针保持不变。

![enter image description here](http://www.liaoxuefeng.com/files/attachments/0013849088235627813efe7649b4f008900e5365bb72323000/0)

最后，`git merge dev` 合并两个分支后的状态

![enter image description here](http://www.liaoxuefeng.com/files/attachments/00138490883510324231a837e5d4aee844d3e4692ba50f5000/0)

两个分支，冲突的情况：

![enter image description here](http://www.liaoxuefeng.com/files/attachments/001384909115478645b93e2b5ae4dc78da049a0d1704a41000/0)

此时，如果 `master`上合并 `feature1`，发生了冲突，手动`merge`并且 `git commit` 后分支状态 「 可用`git log --graph`查看」

![enter image description here](http://www.liaoxuefeng.com/files/attachments/00138490913052149c4b2cd9702422aa387ac024943921b000/0)


`git tag <tagname> [HEAD|commit-id]`
为某个指定的 commit-id 打上永久标签，随后可 `git show <tagname>` 查看 tag 信息

---

#### git 远程库操作

##### `git fetch` 
执行与另一个仓库同步，提取本地没有数据，并为远程仓库的每一个分支提供一个标签。这些分支称为「远程分支」，除了无法`checkout`之外，它们跟本地分支没有区别：可以被合并到当前「本地」分支，与其他分支比较差异，查看这些分支的历史日志等。

`git pull` 等价于 `git fetch` 后 `git merge` 远程分支到当前本地分支。

上述的基本操作流程：

- `git remote add <alias>` 配置远程仓库
- `git fetch <alias>` 更新远程仓库及其分支

```
	$ git fetch github
	remote: Counting objects: 4006, done.
	remote: Compressing objects: 100% (1322/1322), done.
	remote: Total 2783 (delta 1526), reused 2587 (delta 1387)
	Receiving objects: 100% (2783/2783), 1.23 MiB | 10 KiB/s, done.
	Resolving deltas: 100% (1526/1526), completed with 387 local objects.
	From github.com:schacon/hw
	   8e29b09..c7c5a10  master     -> github/master
	   0709fdc..d4ccf73  c-langs    -> github/c-langs
	   6684f82..ae06d2b  java       -> github/java
	 * [new branch]      ada        -> github/ada
	 * [new branch]      lisp       -> github/lisp
```

示例中，从远程仓库新增加了5个分支，并且分别映射为本地名为`github/<branch_name>`的分支。

- `git merge <alias>/<branch>` 合并远程仓库端的更新至本地当前分支

备注：

- `git fetch -all` 同步所有的远程仓库


##### `git push <alias> <branch>` 

推送本地分支数据至远程仓库，即将本地`<branch>`分支数据推送至远程仓库 `<alias>` 上的 `<branch>` 分支。

如果远程分支已存在 `<branch>` 分支，则更新；反之，Git 会「在远程仓库」自动创建该分支。

如果你和另一个开发者同时`clone`了，并都有更新提交；那么当对方推送后你再推送时，默认情况下 Git 不会让你覆盖他的改动。 相反的，它会在你试图推送的分支上执行 git log，确定它能够在你的推送分支的历史记录中看到服务器分支的当前进度。 如果它在你的历史记录中看不到，它就会下结论说你过时了，并打回你的推送。 你需要正式提取、合并，然后再次推送 —— 以确定你把对方的改动也考虑在内了。

	$ git push github master
	To git@github.com:schacon/hw.git
	 ![rejected]        master -> master (non-fast-forward)
	error: failed to push some refs to 'git@github.com:schacon/hw.git'
	To prevent you from losing history, non-fast-forward updates were rejected
	Merge the remote changes before pushing again.  See the 'Note about
	fast-forwards' section of 'git push --help' for details.

手动解决上述问题： `git fetch github; git merge github/master; git push github master`