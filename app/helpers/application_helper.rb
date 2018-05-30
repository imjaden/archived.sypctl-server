# encoding: utf-8
require 'active_support/core_ext/numeric'
module ApplicationHelper
  def flash_message
    return if !defined?(flash) || flash.empty?

    # hash key must be string
    hash = flash.each_with_object({}) do |(k, v), h|
      h[k.to_s] = v
    end
    # bootstrap#v3 [alert] javascript plugin
    flash.keys.map(&:to_s).grep(/warning|danger|success/).map do |key|
      close = link_to('&times;', '#', class: 'close', 'data-dismiss' => 'alert')
      tag(:div, content: %(#{close}#{hash[key]}), class: %(alert alert-#{key}), role: 'alert')
    end.join
  end

  MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' \
                       'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' \
                       'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' \
                       'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' \
                       'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'.freeze
  # check remote client whether is mobile
  # define different layout
  def mobile?
    user_agent = request.user_agent.to_s.downcase

    return false if user_agent =~ /ipad/

    user_agent =~ Regexp.new(MOBILE_USER_AGENTS)
  end

  def android?
    user_agent = request.user_agent.to_s.downcase
    user_agent =~ Regexp.new('android')
  end

  def ios?
    user_agent = request.user_agent.to_s.downcase
    user_agent =~ Regexp.new('iphone|ipad')
  end

  def time_for(value)
    case value
    when :yesterday then Time.now - 24 * 60 * 60
    when :tomorrow  then Time.now + 24 * 60 * 60
    else super
    end
  end
  
  def will_paginater(objects, options = {})
    options = { 
      previous_label: '上一页', 
      next_label: '下一页', 
      renderer: BootstrapPagination::Sinatra, 
      page_links: true, 
      container: false 
    }.merge(options)
    will_paginate objects, options
  end

  def render_page_header
    haml :'../layouts/_header'
  end


  def operation_log_type(mode)
    case mode.to_s.split('.')[0]
    when 'user' then 'mdi-account-edit'
    when 'job' then 'mdi-account-network'
    when 'job_group' then 'mdi-account-group'
    when 'device' then 'mdi-flag'
    when 'device_group' then 'mdi-car'
    when 'app' then 'mdi-beach'
    when 'app_group' then 'mdi-leaf'
    else 'mdi-react'
    end
  end
end
