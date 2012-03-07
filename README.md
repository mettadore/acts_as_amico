# amico

Relationships (e.g. friendships) backed by Redis.

## Installation

`gem install amico`

or in your `Gemfile`

```ruby
gem 'amico'
```

Make sure your redis server is running! Redis configuration is outside the scope of this README, but 
check out the Redis documentation, http://redis.io/documentation.
  
## Usage

Configure amico:

```ruby
Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'default'
  configuration.pending_follow = false
  configuration.page_size = 25
end
```

### Amico module loadable methods:

```ruby
require 'amico'
 => true

Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'default'
  configuration.pending_follow = false
  configuration.page_size = 25
end

class User < ActiveRecord::Base
 is_amico
end

usera = User.create
userb = user.create

usera.follow! userb
=> nil

usera.following? userb
 => true

userb.following? usera
 => false

userb.follow! usera
 => [1, 1]

userb.following? usera
 => true

usera.following_count
 => 1

usera.followers_count
 => 1

userb.unfollow! usera
 => [1, 1, 1, 1, 0]

userb.following_count
 => 0

usera.following_count
 => 1

usera.follower? userb
 => false

puts userb.id
 => 11

usera.following
 => ["11"]

usera.block! userb
 => [1, 0, 1, 0, 0, 0, 0, 1]

userb.following? usera
 => false

usera.blocked? userb
 => true

usera.unblock! userb
 => true

usera.blocked? userb
 => false

userb.follow! usera
 => nil

usera.follow! userb
 => [1, 1]

usera.reciprocated? userb
 => true

puts userb.id
 => 11

usera.reciprocated
 => ["11"]
```

You can also use non-id keys:

```ruby
class Admin < ActiveRecord::Base
  is_amico :amico_key => "name"
  validates_uniqueness_of :name  # -> do this or be sorry :)
end

usera = User.create

puts usera.id
 => 18

admin = Admin.create :name => "frank"

usera.follow! admin
 => nil

admin.follow! usera
 => [1, 1]

admin.followers
 => ["18"]

usera.followers
 => ["frank"]
```

## Documentation 

All library functions can be accessed either through instance methods is an "acts_as"-like way as above, or directly through the Amico module as
discussed in [the example API usage page](https://github.com/mettadore/amico/blob/master/API.md). The "acts_as" methods
are feature complete with the Amico module methods.

The source for the [relationships module](https://github.com/agoragames/amico/blob/master/lib/amico/relationships.rb) is well-documented. There are some
simple examples in the method documentation. You can also refer to the [online documentation](http://rubydoc.info/github/agoragames/amico/master/frames).

## Future Plans

## FAQ?

### Why use Redis sorted sets and not Redis sets?

Based on the work I did in developing [leaderboard](https://github.com/agoragames/leaderboard), 
leaderboards backed by Redis, I know I wanted to be able to page through the various relationships. 
This does not seem to be possible given the current set of commands for Redis sets. 

Also, by using the "score" in Redis sorted sets that is based on the time of when a relationship 
is established, we can get our "recent friends". It is possible that the scoring function may be 
user-defined in the future to allow for some specific ordering.
  
## Contributing to amico
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 David Czarnecki. See LICENSE.txt for further details.

