# Search-gov Info

## Code Status

 [![Build Status](https://circleci.com/gh/GSA/search-gov.svg?style=svg)](https://circleci.com/gh/GSA/search-gov)
 [![Maintainability](https://api.codeclimate.com/v1/badges/fd0577360749c9b3d166/maintainability)](https://codeclimate.com/github/GSA/search-gov/maintainability)

## Contributing to search-gov
Read our [contributing guidelines](./CONTRIBUTING.md).

## Dependencies

### Ruby

Use [RVM](https://rvm.io/) to install the version of Ruby specified in [.ruby-version](/.ruby-version). 

### NodeJS

Use [NVM](https://github.com/nvm-sh/nvm#installing-and-updating) to install the version of NodeJS specified in the [.nvmrc](/.nvmrc). 

### Docker

Docker can be used to: 1) run just the required services (MySQL, Elasticsearch, etc.) while [running the search-gov application in your local machine](https://github.com/GSA/search-gov#running-the-app), and/or 2) run the entire `search-gov` application in a Docker container.  Please refer to [searchgov-services](https://github.com/GSA/search-services) for detailed instructions on centralized configuration for the services.

When running in a Docker container (option 2 above), the `search-gov` application is configured to run on port [3100](http://localhost:3100/). Required dependencies - ([Ruby](https://github.com/GSA/search-gov#ruby), [NodeJS](https://github.com/GSA/search-gov#nodejs), [Package Manager](https://github.com/GSA/search-gov#package-manager), [Packages](https://github.com/GSA/search-gov#packages), [Gems](https://github.com/GSA/search-gov#gems), [JavaScript dependencies](https://github.com/GSA/search-gov#javascript-dependencies)) - are installed using Docker. However, other data or configuration may need to be setup manually, which can be done in the running container using `bash`.

Using bash to perform any operations on search-gov application running in Docker container, below command needs to be run in `search-services`.

    $ docker compose run search-gov bash

For example, to setup DB in Docker:

    $ docker compose run search-gov bash
    $ bin/rails db:setup

The Elasticsearch service provided by `searchgov-services` is configured to run on the default port, [9200](http://localhost:9200/). To use a different host (with or without port) or set of hosts, set the `ES_HOSTS` environment variable. For example, use following command to run the specs using Elasticsearch running on `localhost:9207`:

    ES_HOSTS=localhost:9207 bundle exec rspec spec

Verify that Elasticsearch 7.17.x is running on the expected port (port 9200 by default):

```bash
$ curl localhost:9200
{
  "name" : "002410188f61",
  "cluster_name" : "es7-docker-cluster",
  "cluster_uuid" : "l3cAhBd4Sqa3B4SkpUilPQ",
  "version" : {
    "number" : "7.17.7",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "78dcaaa8cee33438b91eca7f5c7f56a70fec9e80",
    "build_date" : "2022-10-17T15:29:54.167373105Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

### Package Manager

We recommend using [Homebrew](https://brew.sh/) for local package installation on a Mac.

### Packages

Use the package manager of your choice to install the following packages:

* C++ compiler - required by the [cld3](https://github.com/akihikodaki/cld3-ruby) gem, which we use for language detection
* Google's [protocol buffers](https://developers.google.com/protocol-buffers/) - also required by the cld3 gem
* [Java Runtime Environment](https://www.java.com/en/download/)
* [ImageMagick](https://imagemagick.org/) - required by the Paperclip gem, used for image attachments
* [MySQL client](https://github.com/brianmario/mysql2#installing) - required by the mysql2 gem
* [V8](https://v8.dev/) - required by the libv8 gem

Example of installation on Mac using [Homebrew](https://brew.sh/):

    $ brew install gcc
    $ brew install protobuf
    $ brew install java
    $ brew install imagemagick
    $ brew install mysql@5.7
    $ brew install v8
    
Example of installation on Linux:

    $ apt-get install protobuf-compiler
    $ apt-get install libprotobuf-dev
    $ apt-get install imagemagick
    $ apt-get install default-jre
    $ apt-get install default-mysql-client

### Gems

Use [Bundler](https://bundler.io/) 2.3.8 to install the required gems:

    $ gem install bundler -v 2.3.8
    $ bundle install

Refer to [the wiki](https://github.com/GSA/search-gov/wiki/Gem-Installation-gotchas-and-solutions) to troubleshoot gem installation errors.

### JavaScript dependencies

Use [Yarn](https://classic.yarnpkg.com/en/) to install the required JavaScript dependencies:

    $ npm install --global yarn
    $ yarn install

## Data

### Elasticsearch Indexes

You can create the USASearch-related indexes like this:

    $ rake usasearch:elasticsearch:create_indexes

You can index all the records from ActiveRecord-backed indexes like this:

    $ rake usasearch:elasticsearch:index_all[FeaturedCollection+BoostedContent]

If you want it to run in parallel using Resque workers, call it like this:

    $ rake usasearch:elasticsearch:resque_index_all[FeaturedCollection+BoostedContent]

Note that indexing everything uses whatever index/mapping/setting is in place. If you need to change the Elasticsearch schema first, you can 'recreate' or 'migrate' the index:

**Recreate an index (for development/test environments)**

:warning: The `recreate_index` task should only be used in development or test environments, as it deletes and then recreates the index from scratch:

    $ rake usasearch:elasticsearch:recreate_index[FeaturedCollection]

**Migrate an index (safe for production use)**

In production, if you are changing a schema and want to migrate the index without having it be unavailable while the new index is being populated, do this:

    $ rake usasearch:elasticsearch:migrate[FeaturedCollection]

Same thing, but using Resque to index in parallel:

    $ rake usasearch:elasticsearch:resque_migrate[FeaturedCollection]

### MySQL Database

Create and set up your development and test databases:

    $ rails db:setup
    $ rails db:test:prepare

# Tests

Make sure the unit tests, functional and integration tests run:
    
    # Run the RSpec tests
    $ rspec spec/
    
    # Run the Cucumber integration tests
    $ cucumber features/

    # Run the JavaScript tests
    $ yarn test

Optionally, to only run Cucumber accessibility tests:

    $ cucumber features/ --tags @a11y

The above will call the axe step defined in `features/support/hooks.rb` for any scenario tagged with the `@a11y` tag (but not `@a11y_wip` as these are expected to fail).

## Code Coverage

We require 100% code coverage. After running the tests (both RSpec & Cucumber), open `coverage/index.html` in your favorite browser to view the report. You can click around on the files that have < 100% coverage to see what lines weren't exercised.

## Circle CI

We use [CircleCI](https://circleci.com/gh/GSA/usasearch) for continuous integration. Build artifacts, such as logs, are available in the 'Artifacts' tab of each CircleCI build.


# Code Quality

We use [Rubocop](https://rubocop.org/) for static code analysis. Settings specific to i14y are configured via [.rubocop.yml](.rubocop.yml). Shared settings for all Search.gov repositories should be configured via the [searchgov_style](https://github.com/GSA/searchgov_style) gem.

### Running RuboCop Locally

Basic commands you should frequently use:

- **Generate or update the RuboCop TODO file**. Use this when RuboCop identifies many issues:
```bash
bundle exec rubocop --auto-gen-config
```
- **Autocorrect easy-to-fix offenses** (safe corrections only):
```bash
bundle exec rubocop -a
```
- **Autocorrect all possible offenses, including some more complex cases** (use with caution, review changes carefully):
```bash
bundle exec rubocop -A
```
- **Disable offenses that cannot be automatically corrected** when running autocorrections. Useful if you'd like to quickly apply auto-fixes without manually addressing harder issues immediately:
```bash
bundle exec rubocop -a --disable-uncorrectable
```

or

```bash
bundle exec rubocop -A --disable-uncorrectable
```

It is recommended to always review diff changes after running autocorrection commands to ensure code correctness and maintainability.
# Running the app
## Search

To run test searches, you will need a working Bing API key. You can request one from Bing, or ask a friendly coworker.

1. Add the Bing `BING_WEB_SUBSCRIPTION_ID` to `.env` file:
```  
BING_WEB_SUBSCRIPTION_ID: *****
```
2. Start your local development environment:
```
bin/dev
```
3. Test searches should return results:

**Web results**
* http://localhost:3000/search?affiliate=test_affiliate&query=government

**News results**
* http://localhost:3000/search?affiliate=test_affiliate&query=news
* http://localhost:3000/search/news?affiliate=test_affiliate&channel=1&query=news

**Video results**
* http://localhost:3000/search?affiliate=test_affiliate&query=video
* http://localhost:3000/search/news?affiliate=test_affiliate&channel=3&query=video

## Creating a new local admin account
[Login.gov](https://login.gov) is used for authentication.

To create a new local admin account we will need to:
1. Create an account on Login's sandbox environment.
2. Get the Login sandbox private key from a team member.
3. Add an admin user to your local app.

#### 1. Login sandbox
[Create an account](https://idp.int.identitysandbox.gov/sign_up/enter_email) on Login's sandbox environment. This will need to be a valid email address that you can get emails at. You'll receive a validation email to set a password and secondary authentication method.

#### 2. Get the Login sandbox private key
Ask your team members for the current `config/logindotgov.pem` file. This private key will let your local app complete the handshake with the Login sandbox servers. After adding the PEM file, start or restart your local Rails server.

#### 3. Add a new admin user to your local app
Open the rails console, add a new user with the matching email.
```
u = User.where(email: 'your-real-name+search-local@gsa.gov').first_or_initialize
u.assign_attributes( contact_name: 'admin',
                     first_name: 'search',
                     last_name: 'admin',
                     default_affiliate: Affiliate.find_by_name('usagov'),
                     is_affiliate: true,
                     organization_name: 'GSA',
                   )

u.approval_status = 'approved'
u.is_affiliate_admin = true
u.save!
```

You should now be able to login to your local instance of search.gov.

## Admin
Your user account should have admin privileges set. Now go here and poke around.

<http://localhost:3000/admin>

## Asynchronous tasks
Several long-running tasks have been moved to the background for processing via Resque.

1. Visit the resque-web sinatra app at <http://localhost:3000/admin/resque> to inspect queues, workers, etc.

1. In your admin center, [create a type-ahead suggestion (SAYT)](http://localhost:3000/admin/sayt_suggestions) "delete me". Now [create a SAYT filter](http://localhost:3000/admin/sayt_filters) on the word "delete".

1. Look in the Resque web queue to see the job enqueued.

1. Start a Resque worker to run the job:

   `$ QUEUE=* VERBOSE=true rake environment resque:work`

1. You should see log lines indicating that a Resque worker has processed a `ApplySaytFilters` job:

`resque-workers_1  | *** Running before_fork hooks with [(Job{primary_low} | ApplySaytFilters | [])]`

At this point, you should see the queue empty in Resque web, and the suggestion "delete me" should be gone from the [sayt_suggestions table](http://localhost:3000/admin/sayt_suggestions).

### Queue names & priorities
Each Resque job runs in the context of a queue named 'primary' with priorities assigned at job creation time using the resque-priority Gem.
We have queues named :primary_low, :primary, and :primary_high. When creating a new
background job model, consider the priorities of the existing jobs to determine where your jobs should go. Things like fetching and indexing all
Odie documents will take days, and should run as low priority. But fetching and indexing a single URL uploaded by an affiliate should be high priority.
When in doubt, just use Resque.enqueue() instead of Resque.enqueue_with_priority() to put it on the normal priority queue.

(Note: newer jobs inherit from ActiveJob, using the resque queue adapter. We are in the process of migrating the older jobs to ActiveJob.)

### Scheduled jobs
We use the [resque-scheduler](https://github.com/resque/resque-scheduler) gem to schedule delayed jobs. Use [ActiveJob](http://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html)'s `:wait` or `:wait_until` options to enqueue delayed jobs, or schedule them in `config/resque_schedule.yml`.

Example:

1. In the Rails console, schedule a delayed job:

    `> SitemapMonitorJob.set(wait: 5.minutes).perform_later`

1. Run the resque-scheduler rake task:

    `$ rake resque:scheduler`

1. Check the 'Delayed' tab in [Resque web](http://localhost:3000/admin/resque/delayed) to see your job.

### Additional developer resources
* [Local i14y setup](https://github.com/GSA/search-gov/wiki/Setting-up-i14y-with-usasearch-for-development)

## Production

Precompile assets
```
bin/rails assets:precompile
```
