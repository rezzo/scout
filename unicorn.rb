# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

worker_processes 2 # this should be >= nr_cpus
#pid "/Users/Pablo/Developer/workspace/scout.pid"
pid "/Users/Pablo/Developer/workspace/scout/unicorn.pid"
stderr_path "/Users/Pablo/Developer/workspace/scout/log/unicorn.log"
stdout_path "/Users/Pablo/Developer/workspace/scout/log/unicorn.log"

working_directory "/Users/Pablo/Developer/workspace/scout"
