# Contributing

Thanks for contributing to this repository!

This repository follows the following conventions:

* [Semantic Versioning](https://semver.org/)
* [Keep a Changelog](https://keepachangelog.com/)
* [Conventional Commits](https://www.conventionalcommits.org/)

To contribute a change:

1. Create a branch on the cloned repository with a descriptive name. It helps with project tracking when the branch name starts with the Github issue number,for example: 7-issue-description
2. Make the changes in code.
3. Write [GoLang unit tests](https://golang.org/doc/tutorial/add-a-test) as appropriate.
4. Make commits using the [Conventional Commits](https://www.conventionalcommits.org/) format. This helps with automation for changelog. Update `CHANGELOG.md` in the same commit using the [Keep a Changelog](https://keepachangelog.com). Depending on tooling maturity, this step may be automated.
5. Open a pull request using one of the provided templates. If this pull request is solving a preexisting issue, add the issue reference into the description of the PR.
6. During this time, ensure that all new commits are rebased/merged into your branch so that it remains up to date with the `main` branch.
7. Ensure all of the checks are passing, if it involves an update to a check ensure to ask maintainers to update the tag.
8. Wait for a maintainer of the repository (see CODEOWNERS) to approve.
9. If you have permissions to merge, you are responsible for merging. Otherwise, a CODEOWNER will merge the commit.

### Contribution conditions

1. The code must include a minimum of 80% unit test coverage
1. The code must pass lint test
1. Help resolve any security issues found in the mission ops pipeline


# TODO: better define this

* https://gist.github.com/PurpleBooth/b24679402957c63ec426
* https://gist.github.com/briandk/3d2e8b3ec8daf5a27a62
* https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/setting-guidelines-for-repository-contributors
* https://github.com/github/docs/blob/main/CONTRIBUTING.md
