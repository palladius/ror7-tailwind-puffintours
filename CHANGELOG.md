# CHANGELOG

## v0.6.3 - 2025-08-28

### Added

- Add logo and prod URL to README.md.
- Fix failing test by adding `csv` gem.

## v0.6.2 - 2025-08-28

🇫🇷  fix: Update data for Papà and Alessandro.

## v0.6.1 - 2025-08-28

### Added

- `just make-admin EMAIL` command to make a user an admin.
- Display admin status in user show and edit pages.

## 0.6.0 - 2025-08-25

### Changed

- Updated Ruby version to 3.4.5.

## 0.5.24 - 2024-12-25

### Removed

- ENV from PROD in header.

## 0.5.23 - 2024-12-21

### Added

- `actiontext` gem and made it work.
- Also fixing Trix to allow iframe.

## 0.5.22 - 2024-12-21

### Added

- `DEBUG` variable and made bugs everywhere in page if I see it. Maybe I should use it instead of the other verbose thingy

## 0.5.21 - 2024-12-21

### Added

- DNS

## 0.5.20 - 2024-12-21

### Changed

- CSS for synopsis card.

## 0.5.19 - 2024-12-21

### Changed

- ???

## 0.5.18 - 2024-12-21

### Changed

- After save geminification.

## 0.5.17 - 2024-12-21

### Fixed

- Fixing Gemini locally and in PROD.

## 0.5.16 - 2024-12-21

### Added

- version to header.

## 0.5.15 - 2024-12-21

### Fixed

- Bugfix on Gemini in prod..

## 0.5.14 - 2024-12-21

### Added

- Summarization of article and of main image done and finished! :) Only automation to call it behind the scenese where it gets generated/uploaded is missing.

## 0.5.13 - 2024-12-21

### Added

- Started embedding LangchainRb and Gemini API.

## 0.5.12 - 2024-12-21

### Added

- image support thanks to `cursor.sh` wow!

## 0.5.11 - 2024-01-27

### Breaking Changes

- After my crazy idea of making `BUCKET` ,mandatory and breaking prod, I fixed the CRun install and tried to patch the code too.

## 0.5.10 - 2024-01-27

### Changed

- Relaxing CORS both Rails-side both GCS side. This is driving me crazy

## 0.5.9 - 2024-01-27

### Fixed

- And in fact i get: Looks like something went wrong! Maybe exception is: 💛The keyfile '''private/puffin-tours-secret-key.json''' is not a valid file.💛

## 0.5.8 - 2024-01-27

### Fixed

- Fixed locally! Now the big question is:    WILL SERVER WORK WITH CONFIG that doesnt work there? Forse un bel File./exist? if not nil?

## 0.5.7 - 2024-01-27

### Updated

- Updating all gems hoping it fixes my trix/GCS upload issue

## 0.5.6 - 2024-01-27

### Added

- Add actiontext.css stylesheet for ActionText functionality

## 0.5.5 - 2024-01-??

### Changed

- Changed CORS config AGAIN! Look at subtle difference i just enforced:
- https://guides.rubyonrails.org/v6.0.2.1/active_storage_overview.html#cross-origin-resource-sharing-cors-configuration (origin was missing!)

## 0.5.04 - 2024-01-05

### Fixed

- I've fixed CORS the coward way - enable *. But im quite fed up of all the video/image failures for my family. Will fix sometime soon if this becomes am issue, eg a lot of cross-side lyches. Also removed Admin ugly interface in prod.

## 0.5.03 - 2024-01-05

### Fixed

- Cleaned upo JS - now no errors on client side. Except...
- WebSocket connection to '''ws://localhost:3000/rails/live/reload''' failed:

## 0.5.02 - 2024-01-03

### Changed

- [minor] changed sth on footer to point to my gdoc.

## 0.5.01 - 2023-12-21

### Changed

- [MAJOR CHANGE] reinstalled TailwindCSS - not sure if it worked and/or if it broke anything!

## 0.4.03 - 2023-12-21

### Added

- [Tenerife] Scores on Article done well!

## 0.4.02 - 2023-12-18

### Added

- More graphs and about the app

## 0.4.01 - 2023-12-18

### Added

- Adding comments to Articles..

## 0.3.05 - 2023-12-14

### Fixed

- Fixed some bugs..

## 0.3.04 - 2023-12-14

### Added

- Now renders Youtube and Vimeo videos!

## 0.3.03 - 2023-12-14

### Changed

- Admins can edit all articles

## 0.3.01 - 2023-12-10

### Added

- `is_admin` to Users

## 0.2.03 - 2023-12-09

### Changed

- JS substitution works with a REAL API called :)

## 0.2.02 - 2023-12-09

### Changed

- Some random JS to populate a field on Article as per Bard. Doesnt work yet.

## 0.2.01 - 2023-12-09

### Added

- Synopsis to Article, one for image (Gemini!) and one for text (palm)

## 0.1.14 - 2023-12-09

### Added

- `Chartkick` gem and `langhcianrb` because why not

## 0.1.13 - 2023-10-23

### Changed

- Moved Node from 1.8 to 2.0. as per dockerfile output...

## 0.1.12 - 2023-10-23

### Added

- the 4 DB variables to Cloud Build.

## 0.1.11 - 2023-10-22

### Breaking Changes

- I fixed the public JSON problem but now I broke local dev - ill need to figure it out locally how to pass the right JSON - probably by just exporting ADC ENV to private./bah... lets see I'm too tired for this now.

## 0.1.10 - 2023-10-22

### Changed

- Trying with yarn now... in entrypoint.

## 0.1.9 - 2023-10-22

### Changed

- Lot of UX changes, also added the only boolean in Articles. Yay!

## 0.1.8 - 2023-10-22

### Added

- logo in the homepage

## 0.1.7 - 2023-10-22

### Fixed

- trying to fix RAILS_ENV=production rails assets:precompile in entrypoint8080

## 0.1.6 - 2023-10-22

### Changed

- better docker container. #ThisWorks!

## 0.1.4 - 2023-10-22

### Fixed

- bugfix in `riccardo.rb` - again!

## 0.1.4 - 2023-10-22

### Fixed

- fixed ENV and Rails.application.config.hosts

## 0.1.3 - 2023-10-22

### Fixed

- Fixing Dockerfile removing

## 0.1.2 - 2023-10-21

### Added

- images! Lets hope they work"!

## 0.1.0 - 2023-10-21

### Added

- `lolcat` just for git commit. :)

## 0.1.0 - 2023-10-14

### Added

- actsAsTaggable and bumped mid-version. (should have bumped also at 009)..

## 0.0.9 - 2023-10-14

### Added

- actsAsVotable and migrated DB to it.

## 0.0.8 - 2023-10-13

### Added

- date and event type. Next: Tags!

## 0.0.7 - 2023-08-28

### Changed

- Minor changes to Cloud run

## 0.0.6 - 2023-08-27

### Changed

- Lets test this in the cloud..

## 0.0.5 - 2023-08-27

### Changed

- PostgreS set up and PROD works locally!

## 0.0.4 - 2023-08-27

### Fixed

- Mistake on `cloudbuild.yaml` which i overwrote by mistake.

## 0.0.3 - 2023-08-27

### Added

- First Dockerfile. Lets see...

## 0.0.2 - 2023-08-27

### Changed

- Changed DB and added some PuffinTours specialization in view.

## 0.0.1 - 2023-08-26

### Added

- Added a new `/family` page, with a controller, view and route.
