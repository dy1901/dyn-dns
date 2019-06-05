require './dnspod_api'

ip = ''
sub_domain = ""


config=YAML.load_file(File.expand_path('./config.yml'))
api = DnspodApi.new(config['token_id'], config['token'], config['get_ip_service'])

current_ip     = ip
subdomain_info = api.get_subdomain_info(config['domain'], sub_domain)
record_id      = subdomain_info['id']
registered_ip  = subdomain_info['value'].strip

p api.update_subdomain_ip(record_id, config['domain'], sub_domain, current_ip)




