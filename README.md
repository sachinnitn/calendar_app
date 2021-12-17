# Google Calendar Integration With Rails 6 by Sachin Singh.

## Introduction

This is a demo application where you can find the Google Calendar integrated with Rails 6 application. You will see how to create events in a rails app and send it to your google calendar.

You will also find that how to allow users to signin using google in your rails application.

You will find following items in this demo rails application:

* Bootstrap 4.3, JQuery, Popper.js integrated using webpacker
* Devise implemented where user can signin in using their gmail accounts
* Google Calendar API for integrating with rails

## Development Setup

Prerequisites:

- PostgreSQL
- Bundler
- Node(>= 11.x)
- Yarn
- Ruby(2.6.5)
- Rails(>=6)

```sh
bundle install
yarn install
```
Now you need to setup the database. And you need to run following commands but before running them you need to change the values of username and password of your pg inside
```sh
config/database.yml
```
Once changed, run following commands:

```sh
rails db:create
rails data:migrate
```

Now you are all set. Run following command on your terminal:

```sh
rails server
```
To render css and js assets faster open another tab and run following command:

```sh
./bin/webpack-dev-server
```

Was not able to integrate google calendar push notifications with ngrok so added a background job that syncs the new event addtions/deletions/updates to the database. The job is run every 2 minutes but the duration can be customised by setting CALENDAR_SYNC_DURATION environment variable.
To run the background job to sync google events periodically, run:

```sh
rake jobs:work
```

open browser at: [http://localhost:3000](http://localhost:3000).

## Envorinment Variables

For managing google client id and secret keys I have used the dot-env gem and if you use the same, then create a .env file in your progect and this to .gitignore file.

And create these variables in it:

```
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
CALENDAR_SYNC_DURATION
```
