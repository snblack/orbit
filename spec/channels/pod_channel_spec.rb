require "rails_helper"

RSpec.describe PodChannel, type: :channel do
  let(:user) { create(:user) }
  let(:pod)  { create(:pod, :active) }

  context "участник Pod" do
    before { create(:pod_membership, user: user, pod: pod) }

    it "подтверждает подписку" do
      stub_connection current_user: user
      subscribe(pod_id: pod.id)
      expect(subscription).to be_confirmed
    end

    it "создаёт stream для pod" do
      stub_connection current_user: user
      subscribe(pod_id: pod.id)
      expect(subscription).to be_confirmed
      expect(subscription.streams).to include(PodChannel.broadcasting_for(pod))
    end
  end

  context "не участник" do
    it "отклоняет подписку" do
      stub_connection current_user: user
      subscribe(pod_id: pod.id)
      expect(subscription).to be_rejected
    end
  end

  context "участник другого pod" do
    let(:other_pod) { create(:pod, :active) }
    before { create(:pod_membership, user: user, pod: other_pod) }

    it "отклоняет подписку на чужой pod" do
      stub_connection current_user: user
      subscribe(pod_id: pod.id)
      expect(subscription).to be_rejected
    end
  end
end
