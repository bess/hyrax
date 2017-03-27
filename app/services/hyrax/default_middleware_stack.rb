module Hyrax
  class DefaultMiddlewareStack
    # rubocop:disable Metrics/MethodLength
    def self.build_stack
      ActionDispatch::MiddlewareStack.new.tap do |middleware|
        middleware.use Hyrax::Actors::TransactionalRequest
        middleware.use Hyrax::Actors::OptimisticLockValidator
        middleware.use Hyrax::Actors::CreateWithRemoteFilesActor
        middleware.use Hyrax::Actors::CreateWithFilesActor
        middleware.use Hyrax::Actors::AddAsMemberOfCollectionsActor
        middleware.use Hyrax::Actors::AddToWorkActor
        middleware.use Hyrax::Actors::AssignRepresentativeActor
        middleware.use Hyrax::Actors::AttachFilesActor
        middleware.use Hyrax::Actors::AttachMembersActor
        middleware.use Hyrax::Actors::ApplyOrderActor
        middleware.use Hyrax::Actors::InterpretVisibilityActor
        middleware.use Hyrax::Actors::DefaultAdminSetActor
        middleware.use Hyrax::Actors::ApplyPermissionTemplateActor
        middleware.use Hyrax::Actors::ModelActor
        middleware.use Hyrax::Actors::InitializeWorkflowActor
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
