# Cookstylist

Automatically run Cookstyle on all cookbook repositories by installing a GitHub app on your org.

## Design

At the most basic level Cookstylist works by scanning Github orgs that the app is authorized on for repos that look like Chef Infra cookbooks, autocorrecting those repos with Cookstyle, and opening PRs against the origins.

This is achieved by queuing Github application installation IDs, which provide access to individual GitHub organization, in a [resque](https://github.com/resque/resque) queue. These queues are populated via webhook to catch new installations and via a periodic job that allows us to scan all repositories where Cookstyle is authorized once a day. One or more worker processes then process these installation IDs one at a time.

## Moving Parts

### Cookstylist Reactor

The reactor is a [Sinatra](https://github.com/sinatra/sinatra) app that accepts webhooks from GitHub. The Cookstyle application on GitHub is configured to send webhooks for new installations or new repositories authorized on existing webhooks. The reactor application just queues these installation IDs for full scanning in the `new_install` queue, which is considered the high priority queue.

### Cookstylist Periodic

The periodic app just queues all authorized installation IDs for scanning in the `periodic` queue. This is considered the low priority queue since this is just a daily or weekly background job that would run.

### Cookstylist Worker

The Worker is kicked off via a Rake task due to the design of [resque](https://github.com/resque/resque). This task pulls installation ID entries one at a time off the `new_installation` and `periodic` queues. For each installation ID it grabs all repositories authorized for that installation and processes each repository one at a time. It looks for Ruby repositories that have a metadata.rb somewhere in the repo. If the repo looks like a cookbook it checks out the repo, autocorrects with Cookstyle, and pushes a branch / creates a PR if changes are made. The branch is versioned for the Cookstyle gem and any previous PRs are closed out with a reference to a new PR.

## License

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```