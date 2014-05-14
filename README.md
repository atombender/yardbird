# Yardbird

Documentation generator that uses Yardoc as the parser. It's suitable for both Sinatra and Rails applications.

## Installation

Install as a Rubygem:

    sudo gem install yardbird

Then run:

    $ yardbird

## Usage

    $ yardbird generate myproject/ -o docs.md

## Yardoc extensions

Every API endpoint comment must start with `@apidoc`.

### `@category <label>`

Specify the category — a logic grouping — that the endpoint belongs.

### `@path <path>`

Specify the path to the endpoint.

### `@method <method>`

Specify the method. (Deprecated: `@http`.)

### `@optional [<type>] <name> <description>`

Specify optional parameter. May be repeated.

### `@required [<type>] <name> <description>`

Specify required parameter. May be required.

### `@example <path and query>`

Give example endpoint usage.

### `@status <code> <description>`

Describe response status. May be repeated.

## Example comment

    # @apidoc
    # Returns a list of all agents.
    #
    # @category Agents
    # @path /api/v1/agents
    # @http GET
    # @required [boolean] featured Return featured agents only.
    # @optional [integer] offset Return agents from the given offset.
    # @optional ['yyyy-mm-ddThh:mm'] after Return all agents created after the given date.
    # @status 403 If basic auth username is not 'api' or password is incorrect
    # @status 400 If an invalid parameter is provided.
    # @example /api/v1/agents?featured=true&offset=200&limit=100&before=2014-04-16&after=2014-01-01
    #
    get '/agents' do
      ...
    end
