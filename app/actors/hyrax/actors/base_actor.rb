module Hyrax
  module Actors
    # The Hyrax::BaseActor responds to two primary actions:
    # * #create
    # * #update
    # it must instantiate the next actor in the chain and instantiate it.
    # it should respond to curation_concern, user and attributes.
    class BaseActor < AbstractActor
      attr_reader :cloud_resources

      def create(attributes)
        @cloud_resources = attributes.delete(:cloud_resources.to_s)
        apply_creation_data_to_curation_concern
        apply_save_data_to_curation_concern(attributes)
        save && next_actor.create(attributes) && run_callbacks(:after_create_concern)
      end

      def update(attributes)
        apply_update_data_to_curation_concern
        apply_save_data_to_curation_concern(attributes)
        next_actor.update(attributes) && save && run_callbacks(:after_update_metadata)
      end

      protected

        def run_callbacks(hook)
          Hyrax.config.callback.run(hook, curation_concern, user)
          true
        end

        def apply_creation_data_to_curation_concern
          apply_depositor_metadata
          apply_deposit_date
        end

        def apply_update_data_to_curation_concern
          true
        end

        def apply_depositor_metadata
          curation_concern.depositor = user.user_key
        end

        def apply_deposit_date
          curation_concern.date_uploaded = TimeService.time_in_utc
        end

        def save
          curation_concern.save
        end

        def apply_save_data_to_curation_concern(attributes)
          curation_concern.attributes = clean_attributes(attributes)
          curation_concern.date_modified = TimeService.time_in_utc
        end

        # Cast any singular values from the form to multiple values for persistence
        # also remove any blank assertions
        # TODO this method could move to the work form.
        def clean_attributes(attributes)
          attributes[:license] = Array(attributes[:license]) if attributes.key? :license
          attributes[:rights_statement] = Array(attributes[:rights_statement]) if attributes.key? :rights_statement
          remove_blank_attributes!(attributes)
        end

        # If any attributes are blank remove them
        # e.g.:
        #   self.attributes = { 'title' => ['first', 'second', ''] }
        #   remove_blank_attributes!
        #   self.attributes
        # => { 'title' => ['first', 'second'] }
        def remove_blank_attributes!(attributes)
          multivalued_form_attributes(attributes).each_with_object(attributes) do |(k, v), h|
            h[k] = v.instance_of?(Array) ? v.select(&:present?) : v
          end
        end

        # Return the hash of attributes that are multivalued and not uploaded files
        def multivalued_form_attributes(attributes)
          attributes.select { |_, v| v.respond_to?(:select) && !v.respond_to?(:read) }
        end
    end
  end
end
