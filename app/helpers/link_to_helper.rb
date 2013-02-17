# app/helpers/link_to_helper.rb:
# This module is included into all controllers via controllers/application.rb
# -
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/

module LinkToHelper

    # Links to various models

    # Requests
    def request_url(info_request, options = {})
        show_request_url({:url_title => info_request.url_title}.merge(options))
    end

    def request_path(info_request, options = {})
        request_url(info_request, {:only_path => true}.merge(options))
    end

    def request_link(info_request, cls=nil )
        link_to h(info_request.title), request_path(info_request), :class => cls
    end

    def request_admin_link(info_request, name="admin", cls=nil)
      link_to name, admin_request_show_url(info_request), :class => cls
    end

    def request_both_links(info_request)
        link_to(h(info_request.title), request_url(info_request)) + " (" + link_to("admin", admin_request_show_url(info_request)) + ")"
    end

    def request_details_path(info_request)
        details_request_path(:url_title => info_request.url_title)
    end

    # Incoming / outgoing messages
    def incoming_message_url(incoming_message, options = {})
        return request_url(incoming_message.info_request, options.merge(:anchor => "incoming-#{incoming_message.id}"))
    end

    def incoming_message_path(incoming_message)
        incoming_message_url(incoming_message, :only_path => true)
    end

    def outgoing_message_url(outgoing_message, options = {})
        return request_path(outgoing_message.info_request, options.merge(:anchor => "outgoing-#{outgoing_message.id}"))
    end

    def outgoing_message_path(outgoing_message)
        outgoing_message_url(outgoing_message, :only_path => true)
    end

    def comment_url(comment, options = {})
        request_url(comment.info_request, options.merge(:anchor => "comment-#{comment.id}"))
    end

    def comment_path(comment)
        comment_url(comment, :only_path => true)
    end

    # Respond to request
    def respond_to_last_url(info_request, options = {})
        last_response = info_request.get_last_response
        if last_response.nil?
            show_response_no_followup_url(options.merge(:id => info_request.id))
        else
            show_response_url(options.merge(:id => info_request.id, :incoming_message_id => last_response.id))
        end
    end

    def respond_to_last_path(info_request)
        respond_to_last_url(info_request, :only_path => true)
    end

    # Public bodies
    def public_body_url(public_body, options = {})
        public_body.url_name.nil? ? '' : show_public_body_url(options.merge(:url_name => public_body.url_name))
    end

    def public_body_path(public_body)
        public_body_url(public_body, :only_path => true)
    end

    def public_body_link_short(public_body)
        link_to h(public_body.short_or_long_name), public_body_path(public_body)
    end

    def public_body_link(public_body, cls=nil)
        link_to h(public_body.name), public_body_path(public_body), :class => cls
    end

    def public_body_link_absolute(public_body) # e.g. for in RSS
        link_to h(public_body.name), public_body_url(public_body)
    end

    def public_body_both_links(public_body)
        link_to(h(public_body.name), public_body_url(public_body)) + " (" + link_to("admin", admin_body_show_url(public_body)) + ")"
    end

    # Users
    def user_url(user, options = {})
        show_user_url(options.merge(:url_name => user.url_name))
    end

    def user_path(user)
        user_url(user, :only_path => true)
    end

    def user_link(user, cls=nil)
        link_to h(user.name), user_path(user), :class => cls
    end

    def user_link_for_request(request, cls=nil)
        if request.is_external?
            user_name = request.external_user_name || _("Anonymous user")
            if !request.external_url.nil?
                link_to h(user_name), request.external_url
            else
                user_name
            end
        else
            link_to h(request.user.name), user_path(request.user), :class => cls
        end
    end

    def user_admin_link_for_request(request, external_text=nil, internal_text=nil)
        if request.is_external?
            text = external_text ? external_text : (request.external_user_name || _("Anonymous user")) + " (external)"
        else
            text = internal_text ? internal_text : request.user.name
            link_to(h(text), admin_user_show_url(request.user))
        end
    end

    def user_link_absolute(user)
        link_to h(user.name), user_url(user)
    end

    def user_link(user)
        link_to h(user.name), user_path(user)
    end

    def request_user_link_absolute(request)
        if request.is_external?
            request.external_user_name || _("Anonymous user")
        else
            user_link_absolute(request.user)
        end
    end

    def request_user_link(request)
        if request.is_external?
            request.external_user_name || _("Anonymous user")
        else
            user_link(request.user)
        end
    end

    def user_or_you_link(user)
        if @user && user == @user
            link_to h("you"), user_path(user)
        else
            link_to h(user.name), user_path(user)
        end
    end

    def user_or_you_capital(user)
        if @user && user == @user
            return h("You")
        else
            return h(user.name)
        end
    end

    def user_or_you_capital_link(user)
        link_to user_or_you_capital(user), user_path(user)
    end

    def user_admin_link(user, name="admin", cls=nil)
      link_to name, admin_user_show_url(user), :class => cls
    end

    def user_both_links(user)
        link_to(h(user.name), user_url(user)) + " (" + link_to("admin", admin_user_show_url(user)) + ")"
    end

    # Tracks. feed can be 'track' or 'feed'
    def do_track_url(track_thing, feed = 'track', options = {})
        if track_thing.track_type == 'request_updates'
            track_request_url(options.merge(:url_title => track_thing.info_request.url_title, :feed => feed))
        elsif track_thing.track_type == 'all_new_requests'
            track_list_url(options.merge(:view => 'recent', :feed => feed))
        elsif track_thing.track_type == 'all_successful_requests'
            track_list_url(options.merge(:view => 'successful', :feed => feed))
        elsif track_thing.track_type == 'public_body_updates'
            track_public_body_url(options.merge(:url_name => track_thing.public_body.url_name, :feed => feed))
        elsif track_thing.track_type == 'user_updates'
            track_user_url(options.merge(:url_name => track_thing.tracked_user.url_name, :feed => feed))
        elsif track_thing.track_type == 'search_query'
            track_search_url(options.merge(:query_array => track_thing.track_query, :feed => feed))
        else
            raise "unknown tracking type " + track_thing.track_type
        end
    end

    def do_track_path(track_thing, feed = 'track')
        do_track_url(track_thing, feed, :only_path => true)
    end

    # General pages.
    def search_url(query, params = nil)
        if query.kind_of?(Array)
            query = query - ["", nil]
            query = query.join("/")
        end
        routing_info = {:controller => 'general',
                        :action => 'search',
                        :combined => query,
                        :view => nil}
        if !params.nil?
            routing_info = params.merge(routing_info)
        end
        url = url_for(routing_info)
        # Here we can't escape the slashes, as RFC 2396 doesn't allow slashes
        # within a path component. Rails is assuming when generating URLs that
        # either there aren't slashes, or we are in a query part where you can
        # have escaped slashes. Apache complains if you do include slashes
        # within a path component.
        # See http://www.webmasterworld.com/apache/3279075.htm
        # and also 3.3 of http://www.ietf.org/rfc/rfc2396.txt
        # It turns out this is a regression in Rails 2.1, caused by this bug fix:
        #   http://rails.lighthouseapp.com/projects/8994/tickets/144-patch-bug-in-rails-route-globbing
        url = url.gsub("%2F", "/")

        return url
    end

    def search_path(query, options = {})
        search_url(query, options.merge(:only_path => true))
    end

    def search_link(query)
        link_to h(query), search_url(query)
    end

    # Deprecated helper
    # TODO: Remove in next release
    def admin_url(relative_path)
        warn "[DEPRECATION] admin_url is deprecated. Please remove it from your theme."
        relative_path
    end

    # Deprecated helper
    # TODO: Remove in next release
    def main_url(relative_path, append = nil)
        warn "[DEPRECATION] main_url is deprecated. Please remove it from your theme."
        url_prefix = "http://" + Configuration::domain
        url = url_prefix + relative_path
        if !append.nil?
            begin
                env = Rack::MockRequest.env_for(url)
                req = Rack::Request.new(env)
                req.path_info += append
                url = req.url
            rescue URI::InvalidURIError
                # don't append to it
            end
        end
        return url
    end

    # About page URLs
    def about_url
        return help_general_url(:action => 'about')
    end

    def unhappy_url(info_request = nil)
        if info_request.nil?
            return help_general_url(:action => 'unhappy')
        else
            return help_unhappy_url(:url_title => info_request.url_title)
        end
    end

    # Basic date format
    def simple_date(date)
        date = date.in_time_zone.to_date unless date.is_a? Date

        date_format = _("simple_date_format")
        date_format = :long if date_format == "simple_date_format"
        return I18n.l(date, :format => date_format)
    end

    def simple_time(date)
        return date.strftime("%H:%M:%S").strip
    end

    def year_from_date(date)
        return date.strftime("%Y").strip
    end

    #I18n locale switcher

    def locale_switcher(locale, params)
        params['locale'] = locale
        return url_for(params)
    end

end

