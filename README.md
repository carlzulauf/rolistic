# Rolistic

A simple DSL for role-based permissions.

Inspired by tools like [`cancan`](https://github.com/ryanb/cancan) and [`pundit`](https://github.com/elabs/pundit) but intended to be even simpler.

All permissions are identified by a single ability name. No need for objects or methods to manage policies for every type of domain object. Have a complex edge case? Just create a new ability for it specifically.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rolistic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rolistic

## Usage

Create a class to house your roles and their permissions.

```ruby
class ForumRole
  include Rolistic
  # traits allow you to categorize abilities shared by multiple roles
  trait :moderation, %i(delete_thread edit_thread)

  role :anonymous, %i(vote_in_polls reply_to_thread), default: true

  # roles can inherit abilities from existing roles, plus add their own
  role :registered, :anonymous, %i(edit_own_thread create_thread)

  role :moderator, :registered, :moderation
  role :silent_moderator, :moderation

  # special `everything` trait has access to all abilities, even unnamed ones
  role :developer, :everything
end
```

Instances of your role class tell you what they can do.

```ruby
ForumRole.new(:registered).can?(:vote_in_polls) # => true
ForumRole.new("moderator").can?(:edit_thread)   # => true
ForumRole.new(:anonymous).can?(:create_thread)  # => false
ForumRole.new(:developer).can?(:introduce_bugs) # => true

# Use the default role
ForumRole.new.can?(:reply_to_thread) # => true
```

If you are using `ActiveRecord` your role class can easily be serialized to any string column.

```ruby
class User < ApplicationRecord
  serialize :role, ForumRole
  delegate :can?, to: :role
end

User.new(role: "registered").can?(:create_thread) # => true
```

More usage examples can be found in `spec/rolistic_spec.rb`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carlzulauf/rolistic. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
