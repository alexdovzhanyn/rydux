# Rydux

A ruby gem that brings the functionality of Redux to your backend.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rydux'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rydux

## Usage

1. Require the gem somewhere in the _root_ of your application (or somewhere the store will be accessible everywhere you need it).
2. Create some reducers in your application, you can place them anywhere, but a `reducers/` directory is recommended. A sample reducer looks something like this:

  ```ruby
  # reducers/user_reducer.rb

  class UserReducer < Rydux::Reducer

    # Your reducer MUST have a map_state function in order to do anything.
    def self.map_state(action, state = {})
      case action[:type]
      when 'SOME_RANDOM_ACTION' # You can add as many actions here as you'd like
        state.merge(some_random_data: true)
      when 'APPEND_PAYLOAD'
        state.merge(action[:payload])
      else
        state
      end
    end

  end

  ```

3. Create a store somewhere easily accessible in your application:
  ```ruby
    require 'reducers/user_reducer'

    # The key passed into .new here is the key at which this value
    # will be stored in the state. E.g. { user: whatever_user_state }
    Store = Rydux::Store.new(user: UserReducer)

  ```
4. Have something subscribe to the store:
  ```ruby
    class MyClass
      def initialize
        Store.subscribe(self)
      end

      # Every instance that subscribes to the store will
      # get this state_changed method called whenever the state
      # in the store changes. Do whatever you want with your state here.
      def state_changed(state)
        # ...
      end
    end
  ```
5. To update the store with new data, you can `dispatch` actions, like so:
  ```ruby
    Store.dispatch(type: 'SOME_RANDOM_ACTION')
  ```

### Putting it all together:

```ruby
require 'rydux'

class UserReducer < Rydux::Reducer
  @@initial_state = { name: 'Alex', age: 20 }

  def self.map_state(action, state = @@initial_state)
    case action[:type]
    when 'CHANGE_USER_NAME'
      state.merge(name: action[:payload][:name])
    else
      state
    end
  end

end

Store = Rydux::Store.new(user: UserReducer)

class Friend
  def initialize
    Store.subscribe(self)
    @users_name = Store.state.user.name
  end

  def state_changed(state)
    @users_name = state.user.name
  end

  def greet_user
    puts "Hello, #{@users_name}"
  end
end

# Create a new friend (this will subscribe it to the store)
friend = Friend.new
friend.greet_user #=> Hello, Alex

# Change a value in the store
Store.dispatch(type: 'CHANGE_USER_NAME', payload: { name: 'Mike' })
friend.greet_user #=> Hello, Mike
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alexdovzhanyn/rydux. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rydux project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alexdovzhanyn/rydux/blob/master/CODE_OF_CONDUCT.md).
