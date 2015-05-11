# Forcer
[![Gem Version](https://badge.fury.io/rb/forcer.svg)](http://badge.fury.io/rb/forcer)
[![Build Status](https://travis-ci.org/gazazello/forcer.svg?branch=master)](https://travis-ci.org/gazazello/forcer)
[![Code Climate](https://codeclimate.com/github/gazazello/forcer/badges/gpa.svg)](https://codeclimate.com/github/gazazello/forcer)
[![Test Coverage](https://codeclimate.com/github/gazazello/forcer/badges/coverage.svg)](https://codeclimate.com/github/gazazello/forcer/coverage)

Forcer is a ruby command line application and gem designed to help force.com developers who utilize git and proper development process that includes:

1. every developer should have a separate dev_org\dev_sandbox
2. code reviews
3. parallel development of multiple features by a single developer

advantages over traditional ant scripts:

1. Configurability
2. Commands for specific tasks (i.e. delete components or rename components)
3. Easily add REST Api functionality (i.e. load initial data after new org created)


This project is inspired by metaforce. It turned out to be easier to start my own project after trying to understand how metaforce
is written and attempting to contribute into it. So after days of reading metaforces code and trying to understand, how
SOAP api calls are done to salesforce and how 'thor' is used to create command line app, I was ready to write my own tool.
The idea is to make structure of Forcer simpler than metaforce and let contributors understand code by reading smaller amount
of files. I admit that my code is not perfect and far from professional ruby styles, so I will be glad if you help me.
But please lets keep this tool simple with only necessary commands and functionality.

## System Requirements
OS: Mac OS or Linux

Ruby version: 2.1.2 or later

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
Currently the app is tested and being used only on Mac OS and Linux (I used Ubuntu). I have NOT tested on Windows yet, but
if you try and report results on Windows, other developers would be thankful.

Call help to list all available operations for Forcer:

    $(master): forcer help
    deploy ...
    list ...
    ...

To list options and flags available for each command call help for each operation separately:

    $(master): forcer help deploy
    --dest ...
    --checkOnly ...
    ...

To deploy your project (stored in local filesystem) to destination org first from terminal you need to change directory
to project folder that somewhere inside contains folder "src" with all metadata to deploy:

    $(master): cd ~/my_workspace/TestProject/
    $(master): ls
    src
    config
    ...
    
Here is a very simple deploy command:

    $(master): forcer deploy
    
This command will start deployment recursively searching for sfdc project source folder "src" and using the first found for deployment.
Please note that "src" folder must contain a valid package.xml file that you intend to use for deployment.


## Configuration

Users of Forcer gem can configure:

  * Salesforce org authorization details with file "configuration.yml"
  * Components/files/directories to exclude from deployment "exclude_components.yml"
  * XML elements and snippets to exclude from deployment "exclude_xml_nodes.yml"

### Salesforce org authorization details
Forcer can store information about deployment organization to avoid typing details for each deployment. Information like username, 
password (it is strongly recommended to avoid storing password) can be saved in "configuration.yml" file. Best practice
is to keep multiple org information in the same "configuration.yml" (assuming all listed orgs belong to the same project).
This will allow to deploy project directory to any org (of current project) without reentering information. And here is
a template content:

    anything_as_your_org_1_alias:
      host: login.salesforce.com
      username: sample_username1
      password:
      security_token: sample_token1
    anything_as_your_org_2_alias:
      host: login.salesforce.com
      username: sample_username2
      password:
      security_token: sample_token2
      
#### Where should I place "configuration.yml"?
It should be in the same directory where you call Forcer or inside "forcer_config" folder. First "forcer_config" folder
is scanned for configuration.yml file, then current directory (if not found in "forcer_config" folder). More about folder
"forcer_config" at the end of Configuration section.

    $(master): ls
    ./configuration.yml
    ...
    
    $(master): forcer deploy ...
    
This allows having separate "configuration.yml" file for each project. If you are calling Forcer from git repo directory
with project files and keeping the file outside "forcer_config", please add "configuration.yml" to gitignore. This
should help you avoiding committing sensitive data. For more information on setup and usage of configuration.yml please
visit wiki pages of this project. 

### Excluding certain metadata from deployment
Forcer is a flexible tool that allows developers:
    
- Exclude certain components (metadata files) and even whole folders from deployment. For example object Idea.object (excluded by default) usually fails deployments.

    #### How to exclude components and and whole directories from deployment?
    Name of the file is "exclude_components.yml".
    
    #### "exclude_components.yml" contains:
    
        - objects/Idea.object
        - layouts/SocialPersona-Social Persona Layout.layout
        - layouts/SocialPost-Social Post Layout.layout
        - profiles # excludes whole profiles directory
      
    #### Where should I place "exclude_components.yml"?
    Users should use separate "exclude_components.yml" for each project. So best practice is to keep it in folder
    "forcer_config". Read more about it at the end of Configuration section.
    
    Forcer is released with default "exclude_components.yml". If "forcer_config" is not specified, then Forcer will use the
    default file. Users (developers) can modify or replace values to exclude certain components or folders:
    
        [your_ruby_version_location (like ".../rvm/gems/ruby-[version]")]/gems/forcer-[version]/lib/metadata_services/exclude_components.yml
    

- Exclude certain XML elements from deployment. For example all references to "Social..." layouts (excluded by default) in profiles fail deployments.

    #### How to exclude XML elements (snippets) from deployment?
    Name of the file is "exclude_xml_nodes.yml". Goal is to deploy the file/component but filter certain known XML elements
    from teh file.
    
    #### Sample "exclude_xml_nodes.yml":
    
        :".profile":
          - [ "*//layoutAssignments/layout[starts-with('Social')]" , true ]
          - [ "*//tabVisibilities/tab[starts-with('standard-Social')]" , true ]
          
    This means "for all files with filenames ending with '.profiles' do 
       
      find snippets like:
      
          <layoutAsignments>
            <layout>Social blah blah blah</layout>
          </layoutAsignments>
      
      Then take the first parameter which is nokogiri expression. Forcer automatically removes all found nodes from document
      
          <layout>Social blah blah blah</layout>
          
      Then if second parameter is TRUE, remove parent node too. In this example remove
            
          <layoutAsignments>
          </layoutAsignments>
          
      Alternatively if second parameter is FALSE then parent node will remain in the document
          
    The same logic applies for the second sample value:
    
        - [ "*//tabVisibilities/tab[starts-with('standard-Social')]" , true ]
      
    #### Where should I place "exclude_xml_nodes.yml"?
    Users should use separate "exclude_xml_nodes.yml" for each project. So best practice is to keep it in folder
    "forcer_config". Read more about it at the end of Configuration section.
    
    Forcer is released with "exclude_xml_nodes.yml". If "forcer_config" is not specified, then Forcer will use the
    default file. Users (developers) can modify or replace values to exclude xml elements:
    
        [your_ruby_version_location (like ".../rvm/gems/ruby-[version]")]/gems/forcer-[version]/lib/metadata_services/exclude_xml_nodes.yml



All configuration files (configuration.yml, exclude_components.yml, exclude_xml_nodes.yml) for specific project should be
stored in folder "forcer_config" and the folder itself can be specified with command line option "--config":
  
    $(master): forcer deploy --dest my_org_alias --config path_to_forcer_config_folder
  
**Please note the preferred way is to store folder "forcer_config" inside project directory**. In this case it is always
apparent what "forcer_config" belongs to what project:

    $(master): ls -R
    forcer_config
    forcer_config/configuration.yml
    forcer_config/exclude_components.yml
    forcer_config/exclude_xml_nodes.yml
    project
    project/src
    ...
    
Forcer is designed to be used with git. So considering a project directory is git, folder "forcer_config" should be added
to gitignore. Then it can be reused for any branch or salesforce project. The idea is to switch to any branch and be able
to deploy it using "forcer_config" in current project git directory.

### Command line examples
If you already filled configuration.yml correctly then deployments are much faster. Here is a sample command to start deployment of a project in current folder:

    $(master): forcer deploy --dest dest_alias_in_configuration_yml

If you want to call validation-only request then, since it is part of "deploy" soap call, you need to just add flag --checkOnly :

    $(master): forcer deploy --dest dest_alias_in_configuration_yml --checkOnly


Please note almost all options support short aliases. So the same validation-only command will look like:

    $(master): forcer deploy -d dest_alias_in_configuration_yml -c


After Forcer successfully starts deployment (or any other available command) the program also starts printing status
messages in console:

    "initiating DEPLOYMENT"
    "DEPLOYMENT STARTED. YOU CAN ALSO CHECK DEPLOYMENT STATUS IN SALESFORCE ORG."
    "REQUESTING STATUS"
    "STATUS : InProgress | SUCCESS : false"
    "==============="

Please note that messages and language can and will change because the app development is an ongoing process.

## Possible problems

1. When my friend tried to run Forcer on ruby version 2.1.5 on Ubuntu, the app threw exception about missing library
"em-http-request". If you have ruby version 2.1.5 installed and cannot resolve dependencies, probably the simplest
solution is switching to ruby version to 2.1.2 or 2.2.0 or later.
2. openssl library version 1.0.2 on Mac OS (maybe other platforms too) has problems with ruby 2.2.0 when deploy larger
zip-files. In order to fix please follow steps:

        $(master): brew update
        $(master): brew uninstall openssl
        $(master): brew install openssl
        $(master): rvm get head
        $(master): rvm remove 2.2.0
        $(master): rvm install 2.2.0 --with-openssl-dir=`brew --prefix openssl`
        
3. Most probably users will make multiple attempts before the very first deployment succeeds. The reason is Salesforce has
numerous specific features in metadata deployment. And users of Forcer gem will have to:

    * skip/remove certain components from deployment (manually or using exclude_components.xml)
    * filter out certain XML elements from deployment (manually or using exclude_xml_nodes.xml)
    * "username not exist" errors. There are various possible solutions including *sed* program. Example for profiles:
    
        find . -type f -name '*.profile' -exec sed -i '' s/username_org1/username_org2/ {} +
        
    * API version differences between orgs can create issues
    * Salesforce updates can make your current project folder undeployable sometimes
    * other problems requiring modification of XML files
        
4. Contributors may encounter problems with bundler and code-climate if run rspec. The easiest solution is to comment out
these lines in file spec_helper.rb :

        if Gem.available?("codeclimate-test-reporter")
          require "codeclimate-test-reporter"
          CodeClimate::TestReporter.start
        end


## Contributing

1. Fork it ( https://github.com/gazazello/forcer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
