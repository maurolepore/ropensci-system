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
alias ro-email="echo 'reviewtools@ropensci.org'; echo https://groups.google.com/a/ropensci.org/g/reviewtools/about"

# Functions
ro-code-frequency() {
  git log --date=format:"%G-W%V" --pretty=format:"%ad" --numstat | \
    awk 'NF==1 {week=$1; next} $1!="-" {add[week]+=$1; del[week]+=$2} END {for (w in add) printf "%s\t+%d\t-%d\n", w, add[w], del[w]}' | \
    sort
}

