module SolidusUserRoles
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions::Decorators

    engine_name 'solidus_user_roles'
    config.autoload_paths += %W(#{config.root}/lib)

    config.generators do |g|
      g.test_framework :rspec
    end

    def self.load_custom_permissions
      if ActiveRecord::Base.connection.tables.include?('spree_permission_sets')
        ::Spree::Role.non_base_roles.each do |role|
          ::Spree::Config.roles.assign_permissions role.name, role.permission_sets_constantized
        end
      end
    rescue ActiveRecord::NoDatabaseError
      warn 'No database available, skipping role configuration'
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      SolidusUserRoles::Engine.load_custom_permissions unless Rails.env.test?
    end

    config.to_prepare &method(:activate).to_proc
  end
end
