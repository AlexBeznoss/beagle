# Provider recovery verification — October 6, 2026

Implemented on `fix/provider-feed-recovery`: GoRails XML, RemoteOK public API, StartupJobs anonymous official MCP, and WeWorkRemotely RSS. This report describes the initial four-provider change; RubyOnRemote was subsequently recovered in the [follow-up verification](rubyonremote-verification.md). No deployment or paid infrastructure was created during this initial verification.

## Live acquisition and saving

The real `ScrapeJob` was executed against live sources with a dedicated local SQLite database under `tmp/provider-verification/database`, separate from development and production. Image jobs were queued using the test adapter, so this run verified job records and image job scheduling without uploading to production storage.

| Provider | Records saved | Verification |
| --- | ---: | --- |
| GoRails | 1 | Current XML title, company, canonical URL, logo URL, and North America restriction round-trip exactly through the database. |
| RemoteOK | 0 | Live API works and contains 99 jobs; no convincing Ruby roles match. Controlled API tests additionally exercise real saving and updates. |
| StartupJobs | 6 | Live Ruby/Rails queries deduplicate results, save canonical slug IDs, companies/logos, and remote city/state/country restrictions. |
| WeWorkRemotely | 2 | RSS union yields Semaphore and Edfinity, with company, logo and country restrictions; unrelated recruiting boilerplate is excluded. |

Repeating the same captured live batch created no duplicates for any provider. A second Rails process read all nine records back and confirmed exact field equality with the fetched data. Integration tests also run actual parsers and ScrapeJob against controlled HTTP/MCP responses, exercise refreshes, preserve hidden state, and verify transaction rollback and image scheduling on invalid batches.

## Chrome DevTools MCP checks

Chrome DevTools MCP opened the actual public websites and compared their visible content with the extracted records:

- GoRails homepage: Software Developer, Ruby on Rails; E-J Electric Installation Co.; Remote/North America; canonical job link all agree with the XML record.
- WWR Edfinity detail: title/company agree; visible description says Ruby on Rails and requires Rails experience. The page specifies United States work authorization and country. The adapter prefers country over the overly broad feed region "Anywhere in the World".
- StartupJobs SimplePractice detail: title/company and Mexico City, Mexico agree. Although the title includes "Hybrid", the page marks it Remote and explicitly describes a remote role, agreeing with the structured workplace classification.
- RemoteOK `/api` in Chrome: 99 records, zero Ruby/Rails titles, agreeing with the live fetch and healthy empty relevant result.
- The isolated local BeagleJobs board was opened in Chrome. All nine saved records displayed matching titles, companies, geographic restrictions, and outgoing canonical URLs; automated DOM comparisons passed for every record.

Chrome showed Cloudflare challenge pages for the other five StartupJobs details, its Ruby listing, and WWR Semaphore detail in this session. Those individual website comparisons remain incomplete; their records were acquired through the working first-party structured interfaces. This report does not claim all source detail pages were browser-verified.

Raw live saving results, Chrome evidence and the isolated runner are in gitignored `tmp/provider-verification/` for local inspection. The application changes and regression fixtures/tests are tracked normally.

## Final automated checks

- Full Rails suite, including Chrome system tests: **80 tests, 284 assertions, zero failures/errors/skips**.
- RuboCop: **92 files, no offenses**.
- Final live recheck after all fixes: GoRails 1, StartupJobs 6, WWR 2, RemoteOK 0 relevant records; exact database round trips and duplicate checks pass for all four.
- RemoteOK includes an unrelated sales record whose URL is just `/remote-jobs/`. The adapter checks the API field schema, filters relevance, and validates the detail URL for relevant records; this unrelated malformed link no longer blocks the entire source. A regression test covers it.
- Relevance regressions cover negated Ruby requirements and migration-away statements. Image tests cover replacing changed logos, removing cleared logos, and avoiding redundant downloads.

## Coverage and operating limits

- [GoRails XML](https://jobs.gorails.com/jobs.xml) contains published listings and expiration fields. Valid empty feeds are allowed and expired feed entries are ignored.
- [RemoteOK API](https://remoteok.com/api) is a rolling snapshot; historical/category completeness is not established. Attribution and canonical follow links must be retained. Tags alone do not establish a Ruby role.
- [StartupJobs MCP](https://startup.jobs/mcp) supports anonymous filtered search. Free access has a 14-day listing window and a 20-request/minute limit. The adapter fails on missing/repeated cursors or its page cap instead of silently truncating. HTTP 429 is surfaced rather than interpreted as empty data. Provider [API terms](https://startup.jobs/terms/api) include attribution and content-refresh requirements; this change does not introduce a general export or historical backfill.
- [WWR's official RSS page](https://weworkremotely.com/remote-job-rss-feed) advertises syndication feeds. Feed coverage differs: Edfinity was absent from the all-jobs feed but present in full-stack. The union reduces this gap but is not a complete-catalog guarantee. Feed descriptions support contextual filtering; explicit expired entries are ignored.

Existing historical rows are not deleted just because they disappear from a rolling feed. The existing cleanup policy still applies. Polyglot engineering roles with an explicit current Ruby stack are included; incidental tags, negated requirements, obsolete migration stacks, and unrelated marketplace boilerplate are excluded by the deterministic relevance filter.
