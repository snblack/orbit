require "rails_helper"

RSpec.describe ActivitiesController, type: :controller do
  let(:user) { create(:user) }
  let(:pod) { create(:pod, status: "active") }

  before do
    pod.users << user
    sign_in user
  end

  describe "POST #create" do
    it "returns 422 when occurred_on is in the past" do
      post :create, params: { pod_id: pod.id, activity: { occurred_on: Date.yesterday } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "redirects to pod when occurred_on is valid" do
      post :create, params: { pod_id: pod.id, activity: { occurred_on: Date.today + 1 } }
      expect(response).to redirect_to(pod_path(pod))
    end

    it "returns 500 and flash alert when StatementInvalid is raised" do
      allow_any_instance_of(Activity).to receive(:save).and_raise(ActiveRecord::StatementInvalid)
      post :create, params: { pod_id: pod.id, activity: { occurred_on: Date.today + 1 } }
      expect(response).to have_http_status(:internal_server_error)
      expect(flash.now[:alert]).to eq("Ошибка сервера. Попробуйте ещё раз.")
    end
  end
end
