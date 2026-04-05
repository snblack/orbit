require "rails_helper"

RSpec.describe PodsController, type: :controller do
  describe "GET #show" do
    context "when not authenticated" do
      it "redirects to sign in" do
        pod = create(:pod)
        get :show, params: { id: pod.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user) }
      before { sign_in user }

      it "returns 200 for the user's own pod" do
        pod = create(:pod, status: "active")
        pod.users << user
        get :show, params: { id: pod.id }
        expect(response).to have_http_status(:ok)
      end

      it "returns 404 for another user's pod" do
        other_pod = create(:pod)
        get :show, params: { id: other_pod.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
