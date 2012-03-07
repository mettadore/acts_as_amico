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

Amico.follow(1, 11)
=> [1, 1]

Amico.following?(1, 11)
 => true

Amico.following?(11, 1)
 => false

Amico.follow(11, 1)
 => [1, 1]

Amico.following?(11, 1)
 => true

Amico.following_count(1)
 => 1

Amico.followers_count(1)
 => 1

Amico.unfollow(11, 1)
 => [1, 1]

Amico.following_count(11)
 => 0

Amico.following_count(1)
 => 1

Amico.follower?(1, 11)
 => false

Amico.following(1)
 => ["11"]

Amico.block(1, 11)
 => [1, 1, 1, 1, 1]

Amico.following?(11, 1)
 => false

Amico.blocked?(1, 11)
 => true

Amico.unblock(1, 11)
 => true

Amico.blocked?(1, 11)
 => false

Amico.follow(11, 1)
 => nil

Amico.follow(1, 11)
 => [1, 1]

Amico.reciprocated?(1, 11)
 => true

Amico.reciprocated(1)
 => ["11"]
```

Use amico (with pending relationships for follow):

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
  configuration.pending_follow = true
  configuration.page_size = 25
end

Amico.follow(1, 11)
 => true

Amico.follow(11, 1)
 => true

Amico.pending?(1, 11)
 => true

Amico.pending?(11, 1)
 => true

Amico.accept(1, 11)
 => nil

Amico.pending?(1, 11)
 => false

Amico.pending?(11, 1)
 => true

Amico.following?(1, 11)
 => true

Amico.following?(11, 1)
 => false

Amico.follower?(11, 1)
 => true

Amico.follower?(1, 11)
 => false

Amico.accept(11, 1)
 => [1, 1]

Amico.pending?(1, 11)
 => false

Amico.pending?(11, 1)
 => false

Amico.following?(1, 11)
 => true

Amico.following?(11, 1)
 => true

Amico.follower?(11, 1)
 => true

Amico.follower?(1, 11)
 => true

Amico.reciprocated?(1, 11)
 => true
```

Use amico with nicknames instead of IDs. NOTE: This could cause you much hardship later on if you allow nicknames to change.

```ruby
require 'amico'

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

Amico.follow('bob', 'jane')

Amico.following?('bob', 'jane')
 => true

Amico.following?('jane', 'bob')
 => false

Amico.follow('jane', 'bob')

Amico.following?('jane', 'bob')
 => true

Amico.following_count('bob')
 => 1

Amico.followers_count('bob')
 => 1

Amico.unfollow('jane', 'bob')

Amico.following_count('jane')
 => 0

Amico.following_count('bob')
 => 1

Amico.follower?('bob', 'jane')
 => false

Amico.follower?('jane', 'bob')
 => true

Amico.following('bob')
 => ["jane"]

Amico.block('bob', 'jane')

Amico.following?('jane', 'bob')
 => false

Amico.blocked?('bob', 'jane')
 => true

Amico.blocked?('jane', 'bob')
 => false

Amico.unblock('bob', 'jane')
 => true

mico.blocked?('bob', 'jane')
 => false

Amico.following?('jane', 'bob')
 => false

Amico.follow('jane', 'bob')
 => nil

Amico.follow('bob', 'jane')
 => [1, 1]

Amico.reciprocated?('bob', 'jane')
 => true

Amico.reciprocated('bob')
 => ["jane"]
```

Use amico with nicknames instead of IDs and pending follows. NOTE: This could cause you much hardship later on if you allow nicknames to change.

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
  configuration.pending_follow = true
  configuration.page_size = 25
end

Amico.follow('bob', 'jane')

Amico.follow('jane', 'bob')

Amico.pending?('bob', 'jane')
 => true

Amico.pending?('jane', 'bob')
 => true

Amico.accept('bob', 'jane')

Amico.pending?('bob', 'jane')
 => false

Amico.pending?('jane', 'bob')
 => true

Amico.following?('bob', 'jane')
 => true

Amico.following?('jane', 'bob')
 => false

Amico.follower?('jane', 'bob')
 => true

Amico.follower?('bob', 'jane')
 => false

Amico.accept('jane', 'bob')

Amico.pending?('bob', 'jane')
 => false

Amico.pending?('jane', 'bob')
 => false

Amico.following?('bob', 'jane')
 => true

Amico.following?('jane', 'bob')
 => true

Amico.follower?('jane', 'bob')
 => true

Amico.follower?('bob', 'jane')
 => true

Amico.reciprocated?('bob', 'jane')
 => true
```

All of the calls support a `scope` parameter to allow you to scope the calls to express relationships for different types of things. For example:

```ruby
require 'amico'

Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'user'
  configuration.pending_follow = false
  configuration.page_size = 25
end

Amico.follow(1, 11)

Amico.following?(1, 11)
 => true

Amico.following?(1, 11, 'user')
 => true

Amico.following(1)
 => ["11"]

Amico.following(1, {:page_size => Amico.page_size, :page => 1}, 'user')
 => ["11"]

Amico.following?(1, 11, 'project')
 => false

Amico.follow(1, 11, 'project')

Amico.following?(1, 11, 'project')
 => true

Amico.following(1, {:page_size => Amico.page_size, :page => 1}, 'project')
 => ["11"]
```
