# Plan and todos

## todos

- [ ] Add relations between posts
  - skills and projects
- [x] Link books from Goodreads to education
- [ ] Add tests that validate links
- [ ] finish index.md
- [x] Automate publish workflow
- [ ] Finish the tags-archive page

### Automated publish of locally built site to github pages

The jekyll site will be build in the main branch of the portfolio_dev repository. Then, the site can be locally inspected and further altered before actually publishing to Github pages.

If the site is ok to publish, the publish branch should be merged with the main branch, so publish branch contains the updated \_site directory with the correct static files for the webpage. Then a hook should activate updating the martijn-sturm.github.io repository, commit and push it to remote so that the new site is deployed.
