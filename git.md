git 怎么拿到远程以前版本代码
1.把代码clone到本地
2. 使用 git log 查看提交历史并找到你想要的旧版本的commit哈希值
3.使用git checkout加上commit的哈希值来切换到那个版本的代码。
4.如果你想要基于这个旧版本的代码开始新的开发，你可以创建一个新的分支：
5.git checkout -b new-branch-name <commit_hash> 这将会创建并切换到一个新的分支new-branch-name，它的起点是<commit_hash>指定的旧版本