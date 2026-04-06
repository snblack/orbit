require "rails_helper"

RSpec.describe PodChatsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:pod)  { create(:pod, :active) }

  describe "GET #show" do
    context "неаутентифицированный пользователь" do
      it "перенаправляет на sign_in" do
        get :show, params: { pod_id: pod.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "аутентифицированный участник" do
      before do
        create(:pod_membership, user: user, pod: pod)
        sign_in user
      end

      it "возвращает 200" do
        get :show, params: { pod_id: pod.id }
        expect(response).to have_http_status(:ok)
      end

      it "не показывает более 50 сообщений при наличии 60" do
        create_list(:message, 60, pod: pod, user: user)
        get :show, params: { pod_id: pod.id }
        expect(response.body.scan(/id="message-/).length).to be <= 50
      end

      context "с параметром before_id" do
        it "возвращает сообщения старше указанного, исключая pivot и новее" do
          old_msg  = create(:message, pod: pod, user: user, body: "старое")
          pivot    = create(:message, pod: pod, user: user, body: "pivot")
          newer    = create(:message, pod: pod, user: user, body: "новее")

          get :show, params: { pod_id: pod.id, before_id: pivot.id }

          expect(response.body).to include("старое")
          expect(response.body).not_to include("pivot")
          expect(response.body).not_to include("новее")
        end
      end
    end

    context "не участник pod" do
      before { sign_in user }

      it "возвращает 404" do
        get :show, params: { pod_id: pod.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
