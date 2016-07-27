git checkout gh-pages && git merge master && npm run test && npm run build && git commit -am "gh-pages build" && git push && git checkout master
