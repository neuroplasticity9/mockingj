require 'yaml'

VAGRANTFILE_API_VERSION ||= "2"
confDir = $confDir ||= File.expand_path("~/.mockingj")

mockingjYamlPath = confDir + "/mockingj.yaml"
afterScriptPath = confDir + "/after.sh"
aliasesPath = confDir + "/aliases"

require File.expand_path(File.dirname(__FILE__) + '/scripts/mockingj.rb')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    if File.exists? aliasesPath then
        config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
    end

	if File.exists? mockingjYamlPath then
		Mockingj.configure(config, YAML::load(File.read(mockingjYamlPath)))
	end

	if File.exists? afterScriptPath then
		config.vm.provision "shell", path: afterScriptPath
	end
end
