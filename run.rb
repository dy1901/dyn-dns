require './dnspod_api'
require 'daemons'

logger = Logger.new('running.log')
config=YAML.load_file(File.expand_path('./config.yml'))

Daemons.run_proc("dyn-dns") do
  puts 'dyn-dns daemon starting...'
  logger.info('dyn-dns daemon starting...')
  api = DnspodApi.new(config['token_id'], config['token'], config['get_ip_service'])
  loop {
    begin
      current_ip     = api.get_current_ip()
      subdomain_info = api.get_subdomain_info(config['domain'],config['sub_domain'])
      record_id      = subdomain_info['id']
      registered_ip = subdomain_info['value'].strip

      if(current_ip != registered_ip)
        logger.info("Public IP(#{publicIP.strip}) is different from sub-domain IP(#{subDomain['value'].strip}), need to update!")
        api.update_subdomain_ip(record_id, config['domain'], config['sub_domain'], current_ip)
      end
    rescue => e
      logger.info(e.class.to_s() + " occurs, failed to finish the process! Will try next time!")
    end
    sleep(1*60)
  }
end

