# Fides

Adds methods for use in Rails migrations to enforce polymorphic associations at the database level.

### Longer Description

The methods that this gem exposes are for use in Rails migrations and create SQL Triggers to enforce
the data integrity of Polymorphic Associations.

The triggers are invoked by the database before an insert or update on the polymorphic table, and before 
a delete on tables referred to by the polymorphic table.

If an insert/update is attempted on the polymorphic table with a record that refers to a non-existent 
record in another table then a SQL error is raised. If a delete is attempted from a table that is 
referred to by a record in the polymorphic table then a SQL error is raised.

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

      def up
        add_polymorphic_triggers(:polymorphic_model => "Picture", :associated_models => ["Employee", "Product"])
      end

      def down
        remove_polymorphic_triggers(:polymorphic_model => "Picture")
      end
    
    end

If you're using Rails < version 3.1, then use Fides in your migration like this:

    class AddReferentialIntegrityToImageable < ActiveRecord::Migration

      extend Fides

      def self.up
        add_polymorphic_triggers(:polymorphic_model => "Picture", :associated_models => ["Employee", "Product"])
      end

      def self.down
        remove_polymorphic_triggers(:polymorphic_model => "Picture")
      end
    
    end

## Caveats

Fides assumes the use of Rails conventions, so if you find a case for something that needs overriding, 
please feel free to submit a bug or send a pull request.

Fides currently only functions with PostgreSQL. Please feel free to contribute other adapters as desired.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
