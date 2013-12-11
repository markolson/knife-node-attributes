# Knife::Node::Attributes


## Installation

Add this line to your application's Gemfile:

    gem 'knife-node-attributes', git: 'http://github.com/lookingglass/knife-node-attributes'

and run `bundle install`

## Usage

When using Chef-Solo and Knife-Solo, you cannot fetch the node attributes from a last run. 
Instead, this takes a crack at generating them ourselves based on what's in the run_list, environment, role,
and cookbooks..

Given `nodes/staging_web1.json` and a `environments/staging.{rb,json}`


    { "run_list":["role[webapp]"], "environment": "staging" }

You can run `knife node attributes -E staging -N web1 -j nodes/staging_web1.json` to get the attributes that the `Chef::Node` has before the recipes in the cookbooks are run. This means that if you're setting any attributes in the recipes themselves, they will not appear here.

Because the output is sent to STDOUT by default, you can pipe it into other scripts to process it more.
Given a script `versions.rb`:

    #!/usr/bin/env ruby
    require 'json'
    JSON.parse($stdin.read).each {|k,v|
      print %Q("#{k}", "#{v['version']}"\n) if v.is_a?(Hash) && v.has_key?('version')
    }

You can get a CSV of the versions of everything (with a `version` attribute, at least) that may be on that node by
running `knife node attributes -E staging -N web1 -j nodes/staging_web1.json | ./versions.rb`


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
