
#coding: utf-8
require 'singleton'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
require 'yaml'
require 'logger'
require 'pp'

class DnspodApi

  def initialize token_id, token, get_ip_servcie

    @token          = token
    @inline_token   = "login_token=#{token_id},#{@token}&format=json"
    @get_ip_servcie = get_ip_servcie
    @logger         = Logger.new('running.log')
    @ua             = 'dyn-dns'
  end

  def post(functionAddr, postContent)
    http = Net::HTTP.new("dnsapi.cn", 443)
    http.use_ssl = true
    headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => @ua
    }

    response = http.post2(functionAddr, postContent, headers)

    return response
  end

  def get_current_ip
    return open(@get_ip_servcie).read.strip
  end

  def get_domain_info domain
    url = 'https://dnsapi.cn/Domain.Info'

    response = post(url, @inline_token + "&domain=#{domain}")
    ret = JSON.parse(response.body)

    if(ret['status']['code'] == "1")
      return ret['domain']
    else
      @logger.info("Failed to get domain id...")
      @logger.info(ret['status']['message'])
    end

    return nil
  end

  def get_subdomain_info domain, subdomain
    url = 'https://dnsapi.cn/Record.List'
    response = post(url, @inline_token + "&domain=#{domain}&sub_domain=#{subdomain}")
    ret = JSON.parse(response.body)

    if(ret['status']['code'] == "1")
      return ret['records'][0]
    else
      @logger.info("Failed to get domain id...")
      @logger.info(ret['status']['message'])
    end

    return nil
  end

  def update_subdomain_ip record_id, domain, subdomain, ip
    url = 'https://dnsapi.cn/Record.Modify'

    payload = @inline_token
    payload += "&record_id=#{record_id}"
    payload += "&domain=#{domain}"
    payload += "&sub_domain=#{subdomain}"
    payload += "&record_type=A"
    payload += "&record_line=默认" 
    payload += "&value=#{ip}"
    response = post(url, payload)
    ret = JSON.parse(response.body)

    if(ret['status']['code'] == "1")
      @logger.info("ip of subdomain #{subdomain}.#{domain} updated to #{ip}")
      return true
    else
      @logger.info("Failed to update sub domain ip ...")
      @logger.info(ret['status']['message'])
    end

    return nil
  end

end

# config=YAML.load_file(File.expand_path('./Config.yml'))
# t = DnspodApi.new(config['token_id'], config['token'], config['get_ip_service'])
# # pp t.get_current_ip()
# pp t.get_domain_info(config['domain'])
# pp t.get_subdomain_info(config['domain'],config['sub_domain'])
# pp t.update_subdomain_ip('xxx', config['domain'], config['sub_domain'], "xxx")
