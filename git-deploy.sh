cd public
git init
git remote rm origin
git remote add origin git@github.com:swang-harbin/swang-harbin.github.io.git
git config user.email "337229941@qq.com"
git config user.name "wangshuo"
git add -A
git commit -m "deploy"
git push -f origin deploy
