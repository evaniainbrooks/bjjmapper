[ ![Codeship Status for rollfindr/rollfindr](https://www.codeship.io/projects/18ba74e0-2808-0132-60d4-0ef31da13e21/status)](https://www.codeship.io/projects/37888)
![BJJMapper Logo](https://storage.googleapis.com/bjjmapper/logo.png)

# BJJMapper.com Front End/API

## Codeship CI:
 * rollfindr 
   https://app.codeship.com/projects/37888 - pushing to `production` branch triggers a deployment 
 * rollfindr_services (locationfetchsvc, avatarsvc, timezonesvc) 
   https://app.codeship.com/projects/179360 - pushing to `master` triggers a deployment

## Project Setup:

```shell
rvm use jruby --install
gem install bundler
bundle install
RAILS_ENV=test bundle exec rake db:mongoid:create_indexes
```

## To start the dev server:
```
script/setup_server.sh
script/start_nginx.sh
script/start_puma.sh
```

## To run tests

```
bundle exec rspec -p
bundle exec rake konacha:run
rubocop -R -D --format offenses --format progress app spec
```


```