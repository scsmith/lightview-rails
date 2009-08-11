module Lightview  
  module HelperMethods
    
    # Helper method to create a remote_form_for that that calls Lightview.show() and shows the remote
    # response within the modal box.
    #
    # Note that the request will be a javascript request so use format.js to differntiate from the standard html response
    #  respond_to do |format|
    #    format.js {}
    #  end
    def modal_form_for(record_or_name_or_array, *args, &proc)
      options = args.extract_options!
      options[:modal] ||= true
      remote_form_for(record_or_name_or_array, *(args << options), &proc)
    end

    # Helper method to create a link_to_remote that that calls Lightview.show() and shows the remote
    # response within the modal box.
    #
    # Note that the request will be a javascript request so use format.js to differntiate from the standard html response
    #  respond_to do |format|
    #    format.js {}
    #  end
    def link_to_modal(name, options = {}, html_options = nil)
      options[:modal] ||= true
      options[:method] ||= :get
      link_to_remote_with_href_from_url(name, options, html_options)
    end
    
    # Helper method to create a standard link that calls Lightview.hide() when clicked
    def link_to_close_modal(*args, &proc)
      if block_given?
        options      = args.first || {}
        html_options = args.second
        concat(link_to_close_modal(capture(&block), options, html_options))
      else
        name         = args.first
        options      = args.second || {}
        html_options = args.third || {}
      end

      html_options[:onclick] = (html_options[:onclick] || "") + "Lightview.hide(); return false;"
      html_options[:href] ||= '#'

      link_to(name, options, html_options)
    end
  end
  
  module PrototypeHelper
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :remote_function, :modal
      end
    end
    
    # Extends link_to_remote so that it includes the url in its href field instead of #
    def link_to_remote_with_href_from_url(name, options = {}, html_options = nil)
      # set the href manually so that its the link not # and non js users will follow link
      # this should maybe be removed from the library and be set in an application specific way?
      # why does rails not use this by default?
      html_options ||= {}
      html_options[:href] ||= options[:url]
      link_to_remote(name, options, html_options)
    end
    
    # Extends the standard remote_function to make a request to a modal window and pass ajax options
    # as params to the ajax section of Lightview.show() javascript.
    # Most of this method comes from remote_function and the method is only called if the option
    #   :modal => true is passed
    # todo: add the ability to set different options here instead of in the js file for ajax
    def remote_function_with_modal(options)
      return remote_function_without_modal(options) unless options[:modal] == true
      
      javascript_options = options_for_ajax(options)
      
      # Cannot do update form for lightview windows
      raise "Sorry update is not supported for modal windows" if options[:update]
      
      url_options = options[:url]
      url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
      
      function =
        "Lightview.show({
          href: '#{escape_javascript(url_for(url_options))}',
          rel: 'ajax',
          options: {
            autosize: true,
            ajax: #{javascript_options}
          }
        })"
      
      function = "#{options[:before]}; #{function}" if options[:before]
      function = "#{function}; #{options[:after]}"  if options[:after]
      function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
      function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]
      
      return function
    end
  end
end