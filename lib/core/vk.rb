require 'mechanize'

module Core
  class Vk

    include Logging

    attr_reader :bot_status, :agent

    def initialize(phone, password)
      @logged_in  = false
      @bot_status = { :status => :error, :message => 'initialize error'}

      @phone      = phone
      @password   = password
      @code       = phone[phone.length - 4..phone.length] unless phone.nil? || phone.length < 4

      @agent = Mechanize.new do |a|
        a.user_agent_alias = 'Linux Mozilla'
        a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        a.pre_connect_hooks << lambda { |agent, request| request['X-Requested-With'] = 'XMLHttpRequest' }
      end
    end

    def logged_in?
      @logged_in
    end

    def login
      @agent.get('http://vk.com') do |home_page|
        login_form       = home_page.forms.first
        login_form.email = @phone
        login_form.pass  = @password
        login_form.submit

        check_login
      end

      @agent
    rescue Exception => e
      #TODO: check if login REALLY failed at this point
      logger.error "login failed", e
      nil
    end

    def check_login
      home_page   = security_check
      logout_link = home_page.link_with(:id => 'logout_link')

      @bot_status = { :status => :ok,    :message => 'ok'}
      @bot_status = { :status => :error, :message => 'invalid login/password'} if logout_link.nil?
      #@bot_status = { :status => :error, :message => 'invalid target page'}    if check_target_page.nil?
      @bot_status = { :status => :error, :message => 'geoip error'}            if home_page.uri.to_s =~ /security_check/

      @logged_in  = @bot_status[:status] == :ok
    end

    def get_user_identifiers
      @agent.get('http://vk.com/feed')

      href = @agent.page.link_with(:class => 'hasedit fl_l').href

      @agent.get("http://vk.com#{href}")

      { :vk_username => @agent.page.title, :vk_profile_link => @agent.page.uri.to_s }
    rescue Exception => e
      logger.error "something fucked up while trying to grab user info. here's the error: #{e.message}"
      nil
    end

    # Check existing of page
    #def check_target_page
    #  @agent.get(@target_page)
    #rescue
    #  nil
    #end

    def check_post_response(body)
      #9018<!><!>3<!>3325<!>0<!>                          - group post response
      #9018<!><!>3<!>3325<!>0<!><!int>141<!><!int>160<!>  - discussion post response (141 - number of your post, 160 - dunno :D)
      #9018<!><!>3<!>3325<!>8<!>Access denied<!>          - request error
      #8766<!><!>3<!>3323<!>2<!>811148188578<!>1          - long time captcha
      #8766<!><!>3<!>3323<!>2<!>877498584665<!>0          - short time captcha

      @bot_status = { :status => :error,   :message => 'data send error'}    if body =~ /\d+<!><!>\d+<!>\d+<!>\d+<!>(\D+)<!>/
      @bot_status = { :status => :error,   :message => 'long time captcha'}  if body =~ /\d+<!><!>\d+<!>\d+<!>\d+<!>\d+<!>1/
      @bot_status = { :status => :warning, :message => 'short time captcha'} if body =~ /\d+<!><!>\d+<!>\d+<!>\d+<!>\d+<!>0/
    end

    # code - last 4 didgits of a phone number
    def security_check
      home_page = @agent.get('http://vk.com')

      if home_page.uri.to_s =~ /security_check/ && !@code.nil?
        login_security
      else
        home_page
      end
    end

    def login_security
      get_page_hash(home_page, /hash:\s'(\w+)'/)
      params = {
        :act  => 'security_check',
        :code => @code,
        :to   => home_page.uri.to_s.scan(/to=(.+)&/).flatten.first.to_s,
        :hash => @hash
      }
      @hash = nil

      @agent.post('http://vk.com/login.php', params)
    end

    def get_page_hash(page, regexp)
      page.search('script').each { |script| @hash ||= script.content.scan(regexp).flatten.first }
      @hash
    end

    def get_page_title(page)
      @agent.get(page).title
    rescue Exception => e
      logger.error "Error while getting page title: #{e.message}"
      nil
    end

  end
end
