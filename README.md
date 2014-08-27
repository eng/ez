# EZ

** Version 0.9.8 **

For educational purposes only.  Makes domain modeling in Rails more beginner-friendly by avoiding migrations.

## Usage

```ruby
gem 'ez'
```

## Features


### 1. Domain Modeling Enhancements

* Enables instant modeling without migrations via `models.yml` and `rake ez:tables`.  If things get messed up, use `rake ez:reset_tables` to drop the entire db first.
* In development mode, every action will trigger your table updates automatically.
* You can run `rake ez:tables` once to generate a file named `db/models.yml`.  It will have some self-documenting comments inside of it.
* You can run `rake ez:tables` whenever you modify `db/models.yml` instead of waiting for a browser action.
* You can continue to just run `rake db:migrate` since it triggers `rake ez:tables` before running any pending migrations.

**Syntax Guide for `db/models.yml`**

It's just YAML and the syntax is very simple:

```
Book:
  title: string
  copies_on_hand: integer
  author_id: integer
  created_at: datetime
  updated_at: datetime
  paperback: boolean
```

**(Optional) Variations**

The colon after the model name is optional.

Also, you can often omit the column type and rely on conventions.  I don't recommend this for beginning students, but is very handy for experienced developers.  Rails conventions are embraced in `db/models.yml` resulting in these sensible defaults:

* If a column type isn't specified, it's assumed to be a `string` column.
* Column names ending in `_id` are assumed to be of type `integer`.
* Column names ending in `_at` are assumed to be of type `datetime`.
* Column names ending in `_on` are assumed to be of type `date`.

Also, note that `_id` columns are further assumed to be foreign keys and will automatically trigger a database index for that column.

So the above `Book` could be described as:

```
Book:
  title
  copies_on_hand: integer
  author_id
  created_at
  updated_at
  paperback: boolean
```

Finally, you can specify default values for columns in several ways.  Suppose we want to make sure that `copies_on_hand` always has the value `0` for new rows.  First, the fancy way:

```
Book:
  title
  copies_on_hand: integer, default: 0
  author_id
  created_at
  updated_at
  paperback: boolean
```

The syntax is forgiving, so the comma and colon are just for readability; this would work too:

```
Book:
  title
  copies_on_hand: integer default 0
  author_id
  created_at
  updated_at
  paperback: boolean
```

And for the extra lazy like me, you can use parentheses:

```
Book:
  title
  copies_on_hand: integer(0)
  author_id
  created_at
  updated_at
  paperback: boolean
```

* Boolean columns are assumed to be given a default of `false` if not otherwise specified.


### 2. More Model Enhancements

* Adds ActiveRecord::Base `.read` method so that models have complete *CRUD*: `.create`, `.read`, `.update`, and `.delete`.  When given an integer, `.read` becomes a synonym for `.find`.  When given a hash, it is a synonym for `.where`.
* Adds ActiveRecord::Base `.sample` method to choose a random row.
* Adds ActiveRecord::Base `[id]` method as a synonym for `.find_by(id: ...)`. Especially handy in the console.


### 3. Beginner-friendly "It Just Works" console

* Solves the "no connection" message in Rails >= 4.0.1 (if you try to inspect a model without making a query first) by establishing an initial connection to the development database.
* Shows helpful instructions when console starts, including the list of model classes found in the application.
* Uses Hirb for table-like display. (Requires Hirb ~> 0.7.1)
* Patches Hirb to allow nice table output for `ActiveRecord::Relation` lists (i.e. result of `.all`, `.where`) and hash-like output for single ActiveRecord objects, such as the result of `.find_by(:title => 'Apollo 13')`.


### 4. Controller and View Enhancements

* Easier JSON API calls by calling `EZ.from_api(url)`; returns parsed Ruby hash (or array, etc.)
* Built-in view helper `<%= weather %>` and `EZ.weather` for classroom demo of a JSON API, to get quick hash and avoid gory details.  (Relies on http://openweathermap.org).  Default location is Evanston.  Can pass location: `<%= weather('San Diego, CA') %>`.  The `<%= weather %>` helper just delegates to `EZ.weather`.
* Adds view helper `map` to display a static Google map of any address. Example: `<%= map('Millenium Park, Chicago, IL') %>`
