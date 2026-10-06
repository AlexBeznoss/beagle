# RubyOnRemote recovery verification — October 6, 2026

RubyOnRemote now uses Bright Data Web Unlocker with the encrypted Rails credential `brightdata` and zone `rubyonremote`. Its full crawl runs at 00:00 and 12:00 UTC; the other providers retain their half-hourly schedule. Browserless is no longer used.

## Live acquisition and persistence

The live crawl fetched 11 listing pages and six details in 183 seconds. It produced **153 unique jobs**, matching the site's advertised total. Every record was saved through the real `ScrapeJob` into an isolated test database, and every saved field matched the parsed result. Repeating the captured batch created no duplicates. An independent Rails process replayed the actual captures against the final parser and verified all 153 database records again.

Six abbreviated location lists were expanded from visible detail-page tags. No saved location retained a `+N more` placeholder. The parser intentionally avoids JSON-LD location data: Better Stack's structured data lists countries beyond its visible six permitted regions. Expanded locations are cached for 24 hours.

Live captures and isolated verification scripts/results are in gitignored `tmp/rubyonremote-implementation/`. No production database or storage was modified; image jobs used the test adapter.

## Chrome DevTools MCP

Direct Chrome navigation to the native RubyOnRemote detail page still produced a Cloudflare challenge. Chrome therefore rendered the actual HTML acquired through Bright Data on a local temporary server. Better Stack's title and six visible remote regions (US, Canada, UK, EU, Europe, North America) agreed with the parser and the saved board. The local board also displayed CodePath's expanded 31-region list and E-J Electric's US restriction with correct canonical outgoing links. This verifies the rendered acquired source and saved application display; it does not claim independent direct browser access to the protected site.

## Failure handling and checks

The client validates both outer HTTP status and the target status in Bright Data's JSON envelope. Missing credentials, empty bodies, malformed envelopes, challenged pages, and unexpected target URLs fail explicitly without exposing the key. The parser validates listing fields, fills pagination gaps, deduplicates IDs, and rejects a crawl containing fewer unique jobs than the advertised total. A 50-page cap fails explicitly. Up to four listing pages run concurrently; failed acquisition occurs before persistence.

- Full Rails suite: **100 tests, 343 assertions, zero failures/errors/skips**.
- RuboCop: **95 files, no offenses**.
- Final focused ingestion check after a test-only lint adjustment: **5 tests, 31 assertions, zero failures/errors**.

At the user-provided rate of $1.50 per 1,000 requests, two daily 11-page crawls cost $0.99 per 30-day month before credits. An illustrative six detail refreshes daily adds $0.27, totaling **$1.26/month** before credits. Actual detail requests vary with listings and cache state. This change has not been deployed.
