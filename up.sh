cd ~/data/blog
hexo generate
git add .
git commit -m "fix up"
git push
ssh root@rb001 2>&1 << eeooff
    cd /data/hexo-blog
    git pull
    echo "完成"
eeooff