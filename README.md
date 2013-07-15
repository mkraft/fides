# Fides

Enforces Rails polymorphic associations at the database level.

### Longer Description

Use this gem in Rails migrations to create SQL Triggers to enforce the data integrity of polymorphic associations at the 
database level.

Triggers are invoked by the database before inserts, updates, and deletes to prevent polymorphic associations from 
losing data integrity.

If an insert/update is attempted on a polymorphic table with a record that refers to a non-existent 
record in another table, a SQL error is raised. If a delete is attempted from a table that is 
referred to by a record in the polymorphic table, a SQL error is raised.

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

## Database Adapters

Fides currently functions with `postgresql` and `sqlite3` adapters. Feel free to contribute other adapters as desired 
(ex. `mysql2`), and ensure that the common database integration tests all pass prior to submitting the pull request.

## Tests

    rake test:unit
    rake test:integration:sqlite3
    rake test:integration:postgresql

To run the postgresql integration tests you must first copy test/config/database.yml.example to test/config/database.yml
and customize the values for your local postgres install.
    
