require 'mechanize'

module Core
  class Vk

    attr_reader :bot_status, :agent

    def initialize(email, password, code, target_page)
      @logged_in    = false
      @bot_status = { :status => :error, :message => 'initialize error'}

      @email         = email
      @password      = password
      @code          = code
      @target_page   = target_page

      @agent = Mechanize.new do |a|
        a.user_agent_alias = $bot_config.get_value('user_agent_alias')
        a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        a.pre_connect_hooks << lambda{|agent, request|
          request['X-Requested-With'] = 'XMLHttpRequest'
        }
      end
    end

    def logged_in?
      @logged_in
    end

    def login
      @agent.get($bot_config.get_value('home_page')) do |home_page|
        login_form        = home_page.forms.first
        login_form.email  = @email
        login_form.pass   = @password
        login_form.submit

        check_login
      end
    rescue
      nil
    end

    def check_login
      home_page    = login_security
      logout_link  = home_page.link_with(:id => 'logout_link')

      @bot_status = { :status => :ok, :message => 'running'}
      @bot_status = { :status => :error, :message => 'invalid target page'} if check_target_page.nil?
      @bot_status = { :status => :error, :message => 'invalid login/password'} if logout_link.nil?
      @bot_status = { :status => :error, :message => 'geoip error'} if home_page.uri.to_s =~ /security_check/

      @logged_in  = @bot_status[:status] == :ok
    end

    def check_target_page
      @agent.get(@target_page)
    rescue
      nil
    end

    def check_captcha(body)
      #8766<!><!>3<!>3323<!>2<!>877498584665<!>0 - eng captcha
      #8766<!><!>3<!>3323<!>2<!>811148188578<!>1 - rus captcha
      @bot_status = { :status => :warning, :message => 'short time captcha'} if body =~ /\d+<!><!>\d+<!>\d+<!>\d+<!>\d+<!>0/
      @bot_status = { :status => :error, :message => 'long time captcha'} if body =~ /\d+<!><!>\d+<!>\d+<!>\d+<!>\d+<!>1/
    end

    # code - last 4 didgits of a phone number
    def login_security
      home_page = @agent.get($bot_config.get_value('home_page'))

      unless @code.nil?
        parse_page(home_page, /hash:\s'(\w+)'/)
        params = {
          :act  => 'security_check',
          :code => @code,
          :to   => home_page.uri.to_s.scan(/to=(.+)&/).flatten.first.to_s,
          :hash => @hash
        }
        @hash = nil

        return @agent.post('http://vk.com/login.php', params)
      else
        return home_page
      end
    end

    def parse_page(page, regexp)
      page.search('script').each do |script|
        @hash ||= script.content.scan(regexp).flatten.first
      end
      @hash
    end

    def get_page_title(page)
      @agent.get(page).title
    rescue
      nil
    end

  end
end
