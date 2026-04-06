require "rails_helper"

RSpec.describe MessagesController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:pod)  { create(:pod, :active) }

  describe "POST #create" do
    context "неаутентифицированный пользователь" do
      it "перенаправляет на sign_in" do
        post :create, params: { pod_id: pod.id, message: { body: "Привет" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "аутентифицированный пользователь" do
      before { sign_in user }

      context "участник pod" do
        before { create(:pod_membership, user: user, pod: pod) }

        it "возвращает 200 с html и вызывает broadcast при валидном body" do
          expect(PodChannel).to receive(:broadcast_to).with(pod, hash_including(:sender_id, :html))
          post :create, params: { pod_id: pod.id, message: { body: "Привет" } },
                        as: :json
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to have_key("html")
        end

        it "возвращает 422 JSON когда body превышает 1000 символов" do
          post :create, params: { pod_id: pod.id, message: { body: "a" * 1001 } },
                        as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to have_key("error")
        end

        it "возвращает 422 JSON когда body пустое" do
          post :create, params: { pod_id: pod.id, message: { body: "" } },
                        as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to have_key("error")
        end
      end

      context "не участник pod" do
        it "возвращает 403 JSON" do
          post :create, params: { pod_id: pod.id, message: { body: "Привет" } },
                        as: :json
          expect(response).to have_http_status(:forbidden)
          expect(response.parsed_body).to have_key("error")
        end
      end
    end
  end
end
