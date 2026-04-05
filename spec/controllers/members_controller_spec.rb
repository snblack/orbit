require "rails_helper"

RSpec.describe MembersController, type: :controller do
  let(:user) { create(:user) }
  let(:pod) { create(:pod, status: "active") }
  let(:member) { create(:user) }

  before do
    pod.users << user
    pod.users << member
    sign_in user
  end

  describe "GET #show" do
    it "returns 200 for a member of the same pod" do
      get :show, params: { pod_id: pod.id, id: member.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for a user not in the pod" do
      outsider = create(:user)
      get :show, params: { pod_id: pod.id, id: outsider.id }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when pod_id belongs to a different user's pod" do
      other_pod = create(:pod)
      get :show, params: { pod_id: other_pod.id, id: member.id }
      expect(response).to have_http_status(:not_found)
    end
  end
end
