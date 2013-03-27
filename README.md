# Fides

This gem adds helper methods for use in Rails migrations that creates SQL triggers to enforce the 
integrity of polymorphic associations at the database level.

When an attempt is made to create or update a record in a polymorphic table the SQL trigger checks for
the existance of the referred-to model of the specified type in the other table. If it doesn't exist in 
it throws a descriptive SQL exception.

Similarly, when an attempt is made to delete a record from a table that could be pointed to from the
polymorphic table, a SQL trigger checks that there are no references to it in the polymorphic table. If
there are it throws a SQL exception suggesting changing the delete order.

## Installation

Add this line to your application's Gemfile:

    gem 'fides'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fides

## Usage

Fides has the following public methods:

- `add_polymorphic_triggers`
- `remove_polymorphic_triggers`

Following the [Rails Polymorphic Associations example](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations),
you would do the following in a migration:

  class AddReferentialIntegrityToImageable < ActiveRecord::Migration

    def self.up
      add_polymorphic_triggers(:polymorphic_model => "Picture", :has_many_models => ["Employee", "Product"])
    end

    def self.down
      remove_polymorphic_triggers(:polymorphic_model => "Picture")
    end
  
  end

Fides assumes the use of Rails conventions, so if there's something that needs overriding just open a
bug or shoot me a pull request.

## Caveats

Fides currently only functions with PostgreSQL. Please feel free to contribute other adapters.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
