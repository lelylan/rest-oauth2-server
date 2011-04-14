module RackTestMixin

  def self.included(mod)
    mod.class_eval do
      # This is where we save additional entries.
      def hacked_env
        @hacked_env ||= {}
      end
      
      # Alias the original method for further use.
      alias_method  :original_env, :env

      # Override the method to merge additional headers.
      # Plus this implicitly makes it public.
      def env
        original_env.merge(hacked_env)
      end
    end
  end

end

Capybara::Driver::RackTest.send :include, RackTestMixin


