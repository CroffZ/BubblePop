# Security policy

## Supported versions

Security fixes are made on the repository's default branch. Older tags do not have a separate maintenance or backport commitment; use the latest reviewed version. This is a community project with no guaranteed response time.

## Reporting a vulnerability

Do not publish vulnerability details, credentials, or personal data in public issues or pull requests.

Use GitHub's **Security → Report a vulnerability** on this repository:

https://github.com/CroffZ/BubblePop/security/advisories/new

This channel requires the repository owner to enable private vulnerability reporting. If it is unavailable, open an issue asking **@CroffZ** to enable it, without including exploit details or sensitive information. Wait for a private reporting channel before sharing those details.

Include the affected commit or version, iOS/Xcode versions, reproduction steps, expected impact, and a minimal example without real player data. Please allow time for investigation and a fix before public disclosure.

## Data and scope

BubblePop stores names, scores, and settings in JSON files in the app's local Documents directory. The app does not send these files to a server or include analytics. Device backup behavior is controlled by iOS. Deleting the app removes its local data; clearing the scoreboard removes saved scores only.

Report app, persistence, and repository automation vulnerabilities here. For vulnerabilities in iOS or Xcode itself, use Apple's security reporting process.