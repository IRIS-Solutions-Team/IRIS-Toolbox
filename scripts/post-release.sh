git checkout master
git pull gh-origin master
git push
git checkout dist
git pull gh-origin dist
git push
git checkout develop
git merge master
git push
git push gh-origin develop
