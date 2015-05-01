# Forcer
forcer is a ruby gem designed to help force.com developers who utilize git and proper development process that includes:

1. every developer should have a separate dev_org\dev_sandbox
2. code reviews
3. parallel development of multiple features by a single developer

This project is inspired by metaforce. It turned out to be easier to start my own project after trying to understand how metaforce
is written and attempting to contribute into it. So after days of reading metaforces code and trying to understand, how
SOAP api calls are done to salesforce and how 'thor' is used to create command line app, I was ready to write my own tool.
The idea is to make structure of forcer simpler than metaforce and let contributors understand code by reading smaller amount
of files. I admit that my code is not perfect and far from professional ruby styles, so I will be glad if you (yes I mean you!)
help me. But please lets keep this tool simple with only necessary commands and functionality.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'forcer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install forcer

## Usage

Currently the app is tested and being used only on Mac OS. Sorry Linux/Windows users! But I will do my best to make
forcer available for first Linux and then Windows. Linux is first because it is easier.

call help to list all available operations for forcer:

    $: forcer help
    deploy ...
    list ...
    ...

to list options and flags available for each command call help for each operation separately:

    $: forcer deploy help
    --dest ...
    --checkOnly ...
    ...


Here is a sample command to start deployment of a project in current folder:
    $: forcer deploy --dest dest_alias_in_configuration_yml

This command will recursively search for sfdc project source folder "src" and use the first found for deployment.
Please note that "src" folder must contain a valid package.xml file that you intend to use for deployment.

If you want to call validation-only request then, since it is a part of "deploy" soap call, you need to just add flag --checkOnly :

    $: forcer deploy --dest dest_alias_in_configuration_yml --checkOnly


Please note almost all options support short aliases. So the same validation-only command will look like:

    $: forcer deploy -d dest_alias_in_configuration_yml -c


After program successfully starts deploy (or any other available command) the program starts printing status messages in console:

    "initiating DEPLOYMENT"
    "DEPLOYMENT STARTED. YOU CAN ALSO CHECK DEPLOYMENT STATUS IN SALESFORCE ORG."
    "REQUESTING STATUS"
    "STATUS : InProgress | SUCCESS : false"
    "==============="

Please note that messages and language can and will change because the app development is an ongoing process.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing (surprise surprise! guess the steps!)

1. Fork it ( https://github.com/[my-github-username]/forcer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
