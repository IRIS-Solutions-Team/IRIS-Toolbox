git checkout master
git pull gh-origin master --tags
git push --tags
git checkout dist
git pull gh-origin dist
git push
git checkout develop
git merge master
git push
git push gh-origin develop
