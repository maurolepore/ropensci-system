- [ ] On GitHub switch to ropensci-review-bot
- [ ] Create a new PAT: https://github.com/settings/tokens/new
  - note: yyyy-mm-dd-for-env-in-digitalocean-ropensci-roreviewapi2
  - scopes: `repo` (classic PAT) -- covers public-repo writes and the org team read needed by editor search; `public_repo` alone is not sufficient (alternatively `public_repo` + `read:org`)
  - expire: 90 days
- [ ] Login to the server
- [ ] Copy the script to test the PAT
- [ ] Add the new PAT to .env
  ```bash
  cd /home/shared/roreviewapi/ && sudo vim .env
  ```
  ```bash
  # .env 
  # yyyy-mm-dd-for-env-in-digitalocean-ropensci-roreviewapi2
  GITHUB_PAT=
  ```
- [ ] Comment out the old PAT
  ```bash
  # TODO: Revoke
  # GITHUB_PAT=
  ``` 
- [ ] Restart the service
  ```bash
  sudo docker compose up -d --build
  ```
- [ ] Run the script to test the PAT
- [ ] Test the bot still works: https://github.com/ropenscilabs/statistical-software-review/issues/36
  ```bash
  @ropensci-review-bot similar packages 
  ```
- [ ] Revoke the old PAT: https://github.com/settings/tokens
- [ ] Delete the old PAT from .env
  ```bash
  cd /home/shared/roreviewapi/ && sudo vim .env 
  ```
- [ ] Save the updated .env in a password manager
- [ ] Notify in #review-infra: https://ropensci.slack.com/archives/C0CAN1WUSQ0
  ```
  New GITHUB_PAT in the server ropensci roreviewapi2 at /home/shared/roreviewapi/.env
  TODO paste the info from https://github.com/settings/tokens, e.g.
  for-env-in-digitalocean-ropensci-roreviewapi2 — repo
  Expires on Sat, Feb 20 2027.
  ```
