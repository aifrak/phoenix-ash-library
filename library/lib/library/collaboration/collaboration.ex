defmodule Library.Collaboration do
  use Ash.Domain, otp_app: :library, extensions: [AshJsonApi.Domain]

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
end
