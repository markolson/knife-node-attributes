require 'chef/knife'

module KnifeNodeAttribute
  class NodeAttributes < Chef::Knife
    deps do
      require 'chef/application/solo'
      require 'chef/knife/deps'
      require 'chef/patch_mash'
    end

    banner "knife node attributes NODE"

    option :node_json_path,
      :short => "-j NODE_PATH",
      :long => "--path NODE_PATH",
      :description => "Path to the JSON formatted node file."

    option :node_name,
      :short => "-N NODE",
      :long => "--name NODE",
      :description => "Node name"

    option :ohai_override,
      :long => "--ohai JSON",
      :description => "A JSON string to lay over OHAI data before it is applied.",
      :default => "{}"

    option :output_file,
      :short => "-o PATH",
      :description => "Path to write the JSON results to. If not specified, the data will be written to STDOUT"

    def run
      ui.fatal("You must set an environment with the -E flag.") unless config[:environment]
      ui.fatal("You must set an environment with the -E flag.") unless config[:environment]
      ui.fatal("You must provide the node name with the -N flag.") unless config[:node_name]
      ui.fatal("You must provide the path for the JSON file of this node -n flag.") unless config[:node_json_path]
      exit 1 unless (config[:node_json_path] && config[:environment] && config[:node_name])

      Chef::Config[:solo] = true
      name = Chef::Config[:node_name]

      cl = Chef::CookbookLoader.new(Chef::Config[:cookbook_path])
      cl.load_cookbooks

      node = Chef::Node.build(name)

      ohai = ::Ohai::System.new
      ohai.all_plugins
      automatic = ohai.data

      automatic.merge! JSON.parse(config[:ohai_override])
      node.automatic_attrs.merge! automatic

      node.consume_run_list(JSON.load(File.read(config[:node_json_path])))
      full_run_list = node.expand!('disk')

      cookbooks = full_run_list.recipes.map {|recipe|
        # sets the short cookbook name
        original = recipe =~ /(.+)::[^:]*/ ? $1 : recipe
        # load all the "depends" from metadata as well.
        dependencies = cl[original].metadata.dependencies.keys
        # return both
        [original, dependencies]
      }.flatten.uniq # flatten and uniq the array.
     
      # do some bookkeeping to setup a run context, which is used to keep track of
      # which dependencies have already been loaded.
      events = Chef::EventDispatch::Dispatcher.new
      cookbook_collection = Chef::CookbookCollection.new(cl)
      run_context = Chef::RunContext.new(node, cookbook_collection, events)
     
      # This loads the attributes for each cookbook into the node
      compiler = Chef::RunContext::CookbookCompiler.new(run_context, full_run_list, events)
      compiler.compile_libraries
      compiler.compile_resource_definitions
      compiler.compile_lwrps
      compiler.compile_attributes
    
      out = node.merged_attributes
      if config[:output_file]
        File.open(config[:output_file], 'w') { |f| f.write JSON.pretty_generate(out) }
      else
        print out.to_json
        print "\n"
      end
    end
  end
end