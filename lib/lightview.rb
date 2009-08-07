module Lightview  
  module HelperMethods
    def modal_form_for(record_or_name_or_array, *args, &proc)
      options = args.extract_options!
      options[:modal] ||= true
      remote_form_for(record_or_name_or_array, *(args << options), &proc)
    end

    def link_to_modal(name, options = {}, html_options = nil)
      options[:modal] ||= true
      options[:method] ||= :get
      link_to_remote(name, options, html_options)
    end
    
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