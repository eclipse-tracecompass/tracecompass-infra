# Contributing to Trace Compass Infrastructure Repository

Thanks for your interest in this project.

## How to Contribute

In order to contribute, please first [open an issue][issues] that clearly describes the bug you
intend to fix or the feature you would like to add.

Once you have your code ready for review, please  [open a pull request][pull-requests]. Please follow
the [pull request guidelines][pr-guide]. A committer of the Trace Comass project will then review your 
contribution and help to get it merged.

## Terms of Use

This repository is subject to the [Terms of Use of the Eclipse Foundation][terms]

## Code of Conduct

This project is governed by the [Eclipse Community Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.

## Eclipse Development Process

This Eclipse Foundation open project is governed by the [Eclipse Foundation
Development Process][dev-process] and operates under the terms of the [Eclipse IP Policy][ip-policy].

## Eclipse Contributor Agreement

In order to be able to contribute to Eclipse Foundation projects you must
electronically sign the [Eclipse Contributor Agreement (ECA)][eca].

The ECA provides the Eclipse Foundation with a permanent record that you agree
that each of your contributions will comply with the commitments documented in
the Developer Certificate of Origin (DCO). Having an ECA on file associated with
the email address matching the "Author" field of your contribution's Git commits
fulfills the DCO's requirement that you sign-off on your contributions.

For more information, please see the [Eclipse Committer Handbook][commiter-handbook].

## Pull request guidelines

**Changes to the project** are made by submitting code with a pull request (PR).

* [How to write and submit changes][creating-changes]

**Good commit messages** make it easier to review code and understand why the changes were made.
Please include a:

* *Title:* Concise and complete title written in imperative (e.g. "Update Gitpod demo screenshots"
or "Single-click to select or open trace")
* *Problem:* What is the situation that needs to be resolved? Why does the problem need fixing?
Link to related issues
* *Solution:* What changes were made to resolve the situation? Why are these changes the right fix?
* *Impact:* What impact do these changes have? (e.g. Numbers to show a performance improvement,
screenshots or a video for a UI change)

Other commit information:

* [How to format the message][commit-message-message]

## How to build the docker image (tag 18.04)

```bash
docker build --no-cache --build-arg version=18.04 --build-arg strip=true  -t eclipse/tracecompass-build-env:18.04 .
```

## How to push the docker image to dockerHub under the eclipse organisation
```bash
docker push eclipse/tracecompass-build-env:18.04
```

## Contact

For issues related to the infrastructure, please open a GitHub tracker for the [Trace Compass Infrastructure][tc-infra] or send an email to the [Trace Compass mailing list][mailing-list].

[commit-message-message]: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[commiter-handbook]: https://www.eclipse.org/projects/handbook/#resources-commit
[contact-us]: #contact
[creating-changes]: https://www.dataschool.io/how-to-contribute-on-github/
[dev-process]: https://eclipse.org/projects/dev_process
[eca]: http://www.eclipse.org/legal/ECA.php
[ip-policy]: https://www.eclipse.org/org/documents/Eclipse_IP_Policy.pdf
[issues]: https://github.com/eclipse-tracecompass/tracecompass-infra/issues
[mailing-list]: https://accounts.eclipse.org/mailing-list/tracecompass-dev
[pr-guide]: #pull-request-guidelines
[pull-requests]: https://github.com/eclipse-tracecompass/tracecompass-infra/pulls
[tc-infra]: https://github.com/eclipse-tracecompass/tracecompass-infra
[terms]: https://www.eclipse.org/legal/termsofuse.php