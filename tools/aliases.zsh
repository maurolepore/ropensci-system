alias ro-bot-releases="heroku releases -a radiant-garden-91913"
alias ro-meet-me="echo https://calendar.app.google/ZF6iWndUS3uRVow78 | pbcopy"
alias ro-server="ssh mauro@167.99.34.163"

# peer-review project board
alias ro-project-browse="gh project view 12 -w --owner ropensci"
alias ro-project-query="gh project item-list 12 --owner ropensci --query"
alias ro-project-status='STRING="assignee:@me iteration:@current" && echo $STRING && ro-project-query $STRING --field "Status"'
# gh scoped to specific repos
alias ro-gh-review="gh -R ropensci/software-review"
alias ro-gh-review-meta="gh -R ropensci/software-review-meta"

