# [BeagleJobs](https://beaglejobs.com)

A Ruby job board collecting posts from GoRails, RemoteOK, RubyJobBoard, RubyOnRemote, StartupJobs, and WeWorkRemotely.

## Job sources

GoRails uses its public XML feed. RemoteOK uses its public JSON API with local Ruby/Rails relevance filtering. WeWorkRemotely combines the all-jobs, full-stack, and back-end RSS feeds; this avoids its incomplete Ruby landing page. StartupJobs uses its official anonymous MCP endpoint with Ruby/Rails remote searches and cursor pagination, requiring no API key or browser service. Its free source window covers the last 14 days; extended outages require a separate backfill arrangement. StartupJobs searches match titles/company names, so this adapter retains explicitly relevant role titles rather than claiming complete description-based coverage.

Valid empty responses are successful no-ops for these structured sources. Unexpected schemas, malformed feeds, and API errors fail explicitly. Scraping preserves existing provider IDs, refreshes changed fields and logos, and saves each batch transactionally. RubyOnRemote's existing HTML adapter remains in place for separate investigation. Keep source attribution and links to canonical provider job pages.

See [the provider verification report](docs/provider-verification.md) for live acquisition, Chrome DevTools comparisons, persistence checks, and source coverage limits.

## Development

Use Ruby **4.0.7**, Bundler **4.0.22**, and Node **24.21.0 LTS**. Versions are recorded in `.ruby-version`, `.node-version`, and `.mise.toml`.

```sh
mise install
gem install bundler -v 4.0.22
bundle install
npm ci
bin/setup
bin/dev
```

The app serves the public job board without user accounts. The admin panel, authentication, and bookmarks have been removed. Encrypted production credentials remain necessary for Cloudflare storage and monitoring. SQLite application data lives under `db/<environment>/`; Litestack provides search, jobs, cache, and Action Cable.

The frontend uses importmaps, Stimulus, Turbo, and Tailwind **4.3.3**. Tailwind's theme and sources live in `app/assets/tailwind/application.css`. `package.json` locks the Tailwind forms and typography plugins used by the standalone Tailwind compiler. `bin/dev` starts Rails and the CSS watcher.

## Verification

```sh
env -u RAILS_MASTER_KEY RAILS_ENV=test bin/rails db:prepare
env -u RAILS_MASTER_KEY RAILS_ENV=test bin/rails zeitwerk:check
env -u RAILS_MASTER_KEY RAILS_ENV=test bin/rails test:all
bundle exec rubocop
bundle exec bundler-audit check --update
bundle exec ruby-audit check
bundle exec brakeman -q -w2
npm audit
AWS_EC2_METADATA_DISABLED=true SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bin/rails assets:precompile
docker build -t beagle .
```

Chrome or Chromium is required for browser tests. Set `BROWSER_PATH` if it is not discovered automatically. Browser checks block external requests and verify search, pagination, and theme switching on desktop and mobile. Request tests verify the public board, search, Turbo responses, and removal of the former authenticated routes. Litestack search indexes are initialized before test transactions and after parallel database creation.

Test credentials use `config/credentials/test.key`; the production master key does not substitute for it. CI runs the full test suite, lint, audits, and production asset builds on pushes and pull requests. Clerk credentials are no longer needed locally, in CI, or in production. Existing bookmark and Motor Admin database tables are retained to preserve historical data. `LegacyBookmark` keeps expired-job cleanup compatible with the old bookmark foreign key.

## Production

The Docker image uses official Ruby 4.0.7, installs Node dependencies only during the asset build, and runs as the `rails` user. The entrypoint prepares the database before Foreman starts Rails and the scraper clock. Mount `/data` on a persistent volume and supply production secrets through the deployment environment.

The existing `LITESTACK_DATA_PATH=/data/production.sqlite3` is retained for compatibility. Litestack treats this as a directory, storing the production database at `/data/production.sqlite3/production/data.sqlite3`. Queue and cache paths also retain their existing values. Back up the data volume before deploying the Rails upgrade.

Rails **8.1.4** requires SQLite 2.x. Litestack's published 0.4.4 release still requires SQLite 1.x, so the bundle pins upstream revision `e598e1b1f0d46f45df1e2c6213ff9b136b63d9bf`, which supports SQLite 2. Replace this pin when a compatible release is published. Other transitive versions remain constrained by the latest Rails, Standard, and Minitest Rails releases; `bundle outdated` lists those upstream limits.

`bin/rails fly:console` opens the deployed app console in the `sea` region.
