# CHANGELOG

```
2024-12-21 0.5.23  Added `actiontext` gem and made it work. Also fixing Trix to allow iframe.
2024-12-21 0.5.22  Added `DEBUG` variable and made bugs everywhere in page if I see it. Maybe I should use it instead of the other verbose thingy
2024-12-21 0.5.21  Added DNS
2024-12-21 0.5.20  CSS for synopsis card.
2024-12-21 0.5.19  ???
2024-12-21 0.5.18  After save geminification.
2024-12-21 0.5.17  Fixing Gemini locally and in PROD.
2024-12-21 0.5.16  Added version to header.
2024-12-21 0.5.15  Bugfix on Gemini in prod..
2024-12-21 0.5.14  Summarization of article and of main image done and finished! :) Only automation to call it behind the scenese where it gets generated/uploaded is missing.
2024-12-21 0.5.13  Started embedding LangchainRb and Gemini API.
2024-12-21 0.5.12  Added image support thanks to `cursor.sh` wow!
2024-01-27 0.5.11  After my crazy idea of making `BUCKET` ,mandatory and breaking prod, I fixed the CRun install and
                   tried to patch the code too.
2024-01-27 0.5.10  Relaxing CORS both Rails-side both GCS side. This is driving me crazy
2024-01-27 0.5.9   And in fact i get: Looks like something went wrong! Maybe exception is: 💛The keyfile 'private/puffin-tours-secret-key.json' is not a valid file.💛
2024-01-27 0.5.8   Fixed locally! Now the big question is:    WILL SERVER WORK WITH CONFIG that doesnt work there?
                   Forse un bel File./exist? if not nil?
2024-01-27 0.5.7   Updating all gems hoping it fixes my trix/GCS upload issue
2024-01-27 0.5.6   Add actiontext.css stylesheet for ActionText functionality
2024-01-?? 0.5.5   Changed CORS config AGAIN! Look at subtle difference i just enforced:
                   # https://guides.rubyonrails.org/v6.0.2.1/active_storage_overview.html#cross-origin-resource-sharing-cors-configuration (origin was missing!)
2024-01-05 v0.5.04 I've fixed CORS the coward way - enable *. But im quite fed up of all the video/image failures for my family.
                   Will fix sometime soon if this becomes am issue, eg a lot of cross-side lyches. Also removed Admin
                   ugly interface in prod.
2024-01-05 v0.5.03 Cleaned upo JS - now no errors on client side. Except...
  WebSocket connection to 'ws://localhost:3000/rails/live/reload' failed:
2024-01-03 v0.5.02 [minor] changed sth on footer to point to my gdoc.

2023-12-21 v0.5.01 [MAJOR CHANGE] reinstalled TailwindCSS - not sure if it worked and/or if it broke anything!
2023-12-21 v0.4.03 [Tenerife] Scores on Article done well!
2023-12-18 v0.4.02 More graphs and about the app
2023-12-18 v0.4.01 Adding comments to Articles..
2023-12-14 v0.3.05 Fixed some bugs..
2023-12-14 v0.3.04 Now renders Youtube and Vimeo videos!
2023-12-14 v0.3.03 Admins can edit all articles
2023-12-10 v0.3.01 Added `is_admin` to Users
2023-12-09 v0.2.03 JS substitution works with a REAL API called :)
2023-12-09 v0.2.02 Some random JS to populate a field on Article as per Bard. Doesnt work yet.
2023-12-09 v0.2.01 Added Synopsis to Article, one for image (Gemini!) and one for text (palm)
2023-12-09 v0.1.14 Adding `Chartkick` gem and `langhcianrb` because why not
2023-10-23 v0.1.13 Moved Node from 1.8 to 2.0. as per dockerfile output...
2023-10-23 v0.1.12 Added the 4 DB variables to Cloud Build.
2023-10-22 v0.1.11 BREAKING CHANGE!

                   I fixed the public JSON problem but now I broke local dev - ill need to figure it out locally
                   how to pass the right JSON - probably by just exporting ADC ENV to private./bah... lets see
                   I'm too tired for this now.

2023-10-22 v0.1.10 Trying with yarn now... in entrypoint.
2023-10-22 v0.1.9 Lot of UX changes, also added the only boolean in Articles. Yay!
2023-10-22 v0.1.8 Added logo in the homepage
2023-10-22 v0.1.7 trying to fix RAILS_ENV=production rails assets:precompile in entrypoint8080
2023-10-22 v0.1.6 better docker container. #ThisWorks!
2023-10-22 v0.1.4 bugfix in `riccardo.rb` - again!
2023-10-22 v0.1.4 fixed ENV and Rails.application.config.hosts
2023-10-22 v0.1.3 Fixing Dockerfile removing
2023-10-21 v0.1.2 added images! Lets hope they work"!
2023-10-21 v0.1.0 Added `lolcat` just for git commit. :)
2023-10-14 v0.1.0 Added actsAsTaggable and bumped mid-version. (should have bumped also at 009)..
2023-10-14 v0.0.9 Added actsAsVotable and migrated DB to it.
2023-10-13 v0.0.8 Added date and event type. Next: Tags!
2023-08-28 v0.0.7 Minor changes to Cloud run
2023-08-27 v0.0.6 Lets test this in the cloud..
2023-08-27 v0.0.5  PostgreS set up and PROD works locally!
2023-08-27 v0.0.4  Mistake on `cloudbuild.yaml` which i overwrote by mistake.
2023-08-27 v0.0.3  First Dockerfile. Lets see...
2023-08-27 v0.0.2  Changed DB and added some PuffinTours specialization in view.
2023-08-26 v0.0.1  Initial stesure :)
```
