###
### VIEW INHERITANCE
###

# View inheritance is the ability of a subclassed controller to fall back on
# the views of its parent controller. This code is a adapted from these patches:
# http://dev.rubyonrails.org/ticket/7076

ActionController::Base.class_eval do
  def default_template_name(action_name = self.action_name, klass = self.class)
    if action_name && klass == self.class
      action_name = action_name.to_s
      if action_name.include?('/') && template_path_includes_controller?(action_name)
        action_name = strip_out_controller(action_name)
      end
    end
    if !klass.superclass.method_defined?(:controller_path)
      return "#{self.controller_path}/#{action_name}"
    end
    template_name = "#{klass.controller_path}/#{action_name}"
    if template_exists?(template_name)
      return template_name
    else
      return default_template_name(action_name, klass.superclass)
    end
  end

  #
  # these were deprecated in Rails 2.3
  #

  def template_exists?(path)
    self.view_paths.find_template(path, response.template.template_format)
  rescue ActionView::MissingTemplate
    false
  end

  def template_public?(template_name = default_template_name)
    @template.file_public?(template_name)
  end
end

# View inheritance for partials.
ActionView::Partials.class_eval do
  private
  def _pick_partial_template_with_view_inheritance(partial_path)
    _pick_partial_template_without_view_inheritance(partial_path)
  rescue ActionView::MissingTemplate => original_exception
    raise original_exception if !controller
    controller_class = controller.class
    while controller_class && controller_class.superclass.respond_to?(:controller_path) && cp = controller_class.superclass.controller_path
      basename = File.basename(partial_path)
      dirname = File.dirname(partial_path)
      path = File.join(cp, dirname, "_#{basename}")
      begin
        return self.view_paths.find_template(path, self.template_format)
      rescue ActionView::MissingTemplate
        controller_class = controller_class.superclass
      end
    end
    raise original_exception
  end

  alias_method_chain :_pick_partial_template, :view_inheritance
end

###
### MULTIPLE SUBMIT BUTTONS
###

# It is nice to be able to have multiple submit buttons.  For non-ajax, this
# works fine: you just check the existance in the params of the :name of the
# submit button. For ajax, this breaks, and is labelled wontfix
# (http://dev.rubyonrails.org/ticket/3231). This hack is an attempt to get
# around the limitation. By disabling the other submit buttons we ensure that
# only the submit button that was pressed contributes to the request params.

class ActionView::Base
  alias_method :rails_submit_tag, :submit_tag
  def submit_tag(value = "Save changes", options = {})
    #options[:id] = (options[:id] || options[:name] || :commit)
    options.update(:onclick => "Form.getInputs(this.form, 'submit').each(function(x){if (x!=this) x.disabled=true}.bind(this))")
    rails_submit_tag(value, options)
  end
end


###
### LINK_TO FOR COMMITTEES
###

# I really want to be able to use link_to(:id => 'group+name') and not have
# it replace '+' with some ugly '%2B' character.

class ActionView::Base
  def link_to_with_pretty_plus_signs(*args)
    link_to_without_pretty_plus_signs(*args).sub('%2B','+')
  end
  alias_method_chain :link_to, :pretty_plus_signs
end

###
### CUSTOM FORM ERROR FIELDS
###

# Rails form helpers are brutal when it comes to generating
# error markup for fields that fail validation
# they will surround every input with .fieldWithErrors divs
# and will mess up your layout. but there is a way to customize them
# http://pivotallabs.com/users/frmorio/blog/articles/267-applying-different-error-display-styles
class ActionView::Base
  def with_error_proc(error_proc)
    pre = ActionView::Base.field_error_proc
    ActionView::Base.field_error_proc = error_proc
    yield
    ActionView::Base.field_error_proc = pre
  end
end

###
### PERMISSIONS DEFINITION
###
ActionController::Base.class_eval do
  # defines the permission mixin to be in charge of instances of this controller
  # and related views.
  #
  # for example:
  #   permissions 'foo_bar', :bar_foo
  #
  # will attempt to load the +FooBarPermission+ and +BarFooPermission+ classes
  # and apply them considering permissions for the current controller and views.
  def self.permissions(*class_names)
    for class_name in class_names
      begin
        permission_class = "#{class_name}_permission".camelize.constantize
      rescue NameError # permissions 'groups' => Groups::BasePermission
        permission_class = "#{class_name}/base_permission".camelize.constantize
      end
      include(permission_class)
      add_template_helper(permission_class)

      #@@permissioner = Object.new
      #@@permissioner.extend(permission_class)
    end
  end
end

  # returns the permissioner in charge of instances of this controller class
  #def self.permissioner
  #  @@permissioner
  #end

  # returns the permissioner in charge of this controller class
  #def permissioner
  #  @@permissioner
  #end

###
### HACK TO BE REMOVED WHEN UPGRADING TO RAILS 2.3
###

class ActionView::Base

  def button_to_remote(name, options = {}, html_options = {})
    button_to_function(name, remote_function(options), html_options)
  end

end

###
### handle truncate compatibility betweeen rails 2.1 and 2.3
###
class ActionView::Base
#
# This make truncate compatible with rails 2.1 and rails 2.3
#
  def truncate_with_compatible_code(text, options={})
    length = options[:length] || 30
    omission = options[:omission] || "..."
    if Rails::version == "2.1.0"
      truncate_without_compatible_code(text, length, omission)
    else
      truncate_without_compatible_code(text, options)
    end
  end

  alias_method_chain :truncate, :compatible_code
end
