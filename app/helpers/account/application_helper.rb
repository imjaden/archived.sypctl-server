# encoding: utf-8
module Account
  module ApplicationHelper
    def render_page_header
      haml :'../../layouts/_account_header'
    end
  end
end