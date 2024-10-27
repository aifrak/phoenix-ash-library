defmodule Library.Collaboration do
  use Ash.Domain,
    otp_app: :library,
    extensions: [AshJsonApi.Domain, AshGraphql.Domain, AshAdmin.Domain]

  alias Library.Collaboration.StudyGroup

  resources do
    resource StudyGroup do
      define :create_study_group, action: :create
      define :update_study_group, action: :update
      define :get_study_group_by_id, get_by: :id, action: :read
      define :list_study_groups, action: :read
      define :destroy_study_group, action: :destroy
    end
  end

  json_api do
    prefix "/api/json/collaboration"

    routes do
      # in the domain `base_route` acts like a scope
      base_route "/v1/study-groups", StudyGroup do
        get :read
        index :read
        post :create
        patch :update
        delete :destroy
      end
    end
  end

  graphql do
    queries do
      get StudyGroup, :collaboration_study_group, :read
      list StudyGroup, :collaboration_study_groups, :read
    end

    mutations do
      create StudyGroup, :create_collaboration_study_group, :create
      update StudyGroup, :update_collaboration_study_group, :update
      destroy StudyGroup, :destroy_collaboration_study_group, :destroy
    end
  end

  admin do
    show? true
  end
end
