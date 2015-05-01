# Forcer
[![Gem Version](https://badge.fury.io/rb/forcer.svg)](http://badge.fury.io/rb/forcer)

forcer is a ruby command line application and gem designed to help force.com developers who utilize git and proper development process that includes:

1. every developer should have a separate dev_org\dev_sandbox
2. code reviews
3. parallel development of multiple features by a single developer

advantages over traditional ant scripts:

1. Configurability
2. Easy integration with CI (i.e. Jenkins) 
3. Commands for specific tasks (i.e. delete components or rename components)
4. Easily add REST Api functionality (i.e. load initial data after new org created)


This project is inspired by metaforce. It turned out to be easier to start my own project after trying to understand how metaforce
is written and attempting to contribute into it. So after days of reading metaforces code and trying to understand, how
SOAP api calls are done to salesforce and how 'thor' is used to create command line app, I was ready to write my own tool.
The idea is to make structure of forcer simpler than metaforce and let contributors understand code by reading smaller amount
of files. I admit that my code is not perfect and far from professional ruby styles, so I will be glad if you help me.
But please lets keep this tool simple with only necessary commands and functionality.


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
Currently the app is tested and being used only on Mac OS. I will do my best to make forcer available for Linux and Windows.

Call help to list all available operations for forcer:

    $: forcer help
    deploy ...
    list ...
    ...

To list options and flags available for each command call help for each operation separately:

    $: forcer help deploy
    --dest ...
    --checkOnly ...
    ...

To deploy your project (stored in local filesystem) to destination org first from terminal you need to change directory
to project folder that somewhere inside contains folder "src" with all metadata to deploy:

    $: cd ~/my_workspace/TestProject/
    $: ls
    src
    config
    ...
    
Here is a very simple deploy command:

    $: forcer deploy
    
This command will start deployment recursively searching for sfdc project source folder "src" and using the first found for deployment.
Please note that "src" folder must contain a valid package.xml file that you intend to use for deployment.


### Configuration
forcer can store information about deployment organization to avoid typing details for each deployment. Information like username, 
password (it is strongly recommended to avoid storing password) can be saved in configuration.yml file. And here is a template content:

    anything_as_your_org_alias:
      host: login.salesforce.com
      username: sample_username
      password:
      security_token: sample_token
      
For more information on setup and usage of configuration.yml please visit wiki pages of this project. 

### Excluding certain metadata from deployment
forcer is a flexible tool that allows developers exclude certain:

1. components (metadata files) from deployment. For example object Idea.object (excluded by default) usually fails deployments.
2. XML elements from deployment. For example all references to "Social..." layouts (excluded by default) in profiles fail deployments.

For more information on how to use configuration files to exclude components and XML snippets please visit wiki pages
of this project.


### Command line examples
If you already filled configuration.yml correctly then deployments are much faster. Here is a sample command to start deployment of a project in current folder:

    $: forcer deploy --dest dest_alias_in_configuration_yml

If you want to call validation-only request then, since it is part of "deploy" soap call, you need to just add flag --checkOnly :

    $: forcer deploy --dest dest_alias_in_configuration_yml --checkOnly


Please note almost all options support short aliases. So the same validation-only command will look like:

    $: forcer deploy -d dest_alias_in_configuration_yml -c


After forcer successfully starts deploy (or any other available command) the program starts printing status messages in console:

    "initiating DEPLOYMENT"
    "DEPLOYMENT STARTED. YOU CAN ALSO CHECK DEPLOYMENT STATUS IN SALESFORCE ORG."
    "REQUESTING STATUS"
    "STATUS : InProgress | SUCCESS : false"
    "==============="

Please note that messages and language can and will change because the app development is an ongoing process.


## Contributing

1. Fork it ( https://github.com/gazazello/forcer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
