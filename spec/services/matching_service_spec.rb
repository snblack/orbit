require "rails_helper"

RSpec.describe MatchingService do
  def nearby_user(lat: 53.9, lon: 27.5, **attrs)
    create(:user, latitude: lat, longitude: lon, **attrs)
  end

  describe ".run" do
    context "AC-11: начальный пул меньше 5 пользователей" do
      it "возвращает сообщение и не создаёт pod" do
        create_list(:user, 3)
        result = nil
        expect { result = MatchingService.run }.not_to change(Pod, :count)
        expect(result).to eq("Not enough users to form a pod.")
      end
    end

    context "AC-1: 5+ совместимых пользователей рядом" do
      it "создаёт active pod из 5 участников" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        pod = Pod.last
        expect(pod.status).to eq("active")
        expect(pod.users.count).to eq(5)
      end
    end

    context "AC-2: пользователи без onboarding_completed исключаются" do
      it "не включает неонбордированных в pod" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        excluded = create(:user, latitude: 53.9, longitude: 27.5, onboarding_completed: false)
        MatchingService.run
        expect(Pod.all.flat_map(&:users)).not_to include(excluded)
      end
    end

    context "AC-3: идемпотентность — пользователи уже в поде пропускаются" do
      it "не добавляет их повторно при повторном запуске" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        expect { MatchingService.run }.not_to change(Pod, :count)
      end
    end

    context "AC-4: score < 3 → кандидат не попадает в pod" do
      it "не добавляет несовместимого пользователя в active pod" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        incompatible = create(:user,
          latitude: 53.9, longitude: 27.5,
          life_phase: :retired,
          social_style: :extrovert,
          friendship_goal: :fun,
          openness_level: :deep,
          social_frequency: :daily,
          schedule_preference: {}
        )
        MatchingService.run
        active_pods = Pod.where(status: "active")
        expect(active_pods.flat_map(&:users)).not_to include(incompatible)
      end
    end

    context "AC-5: schedule_score" do
      it "возвращает 1.0 при одном совпадающем слоте" do
        service = MatchingService.new
        expect(service.send(:schedule_score, { "mon" => true }, { "mon" => true })).to eq(1.0)
      end

      it "возвращает 1.4 при трёх совпадающих слотах" do
        a = { "mon" => true, "wed" => true, "fri" => true }
        service = MatchingService.new
        expect(service.send(:schedule_score, a, a)).to eq(1.4)
      end
    end

    context "AC-6: радиус не выходит за 30 км" do
      it "не включает пользователя за пределами 30 км в active pod" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        far_user = create(:user, latitude: 54.9, longitude: 27.5)
        MatchingService.run
        expect(Pod.where(status: "active").flat_map(&:users)).not_to include(far_user)
        expect(Pod.where(status: "inactive").flat_map(&:users)).to include(far_user)
      end
    end

    context "AC-7: кандидатов < 4 в радиусе 30 км → inactive pod" do
      it "создаёт inactive pod когда не набирается 4 кандидата" do
        create_list(:user, 4, latitude: 53.9, longitude: 27.5)
        create_list(:user, 2, latitude: 54.9, longitude: 27.5)
        MatchingService.run
        expect(Pod.first.status).to eq("inactive")
      end
    end

    context "AC-8: остаток пула < 5 → один inactive pod" do
      it "собирает 2 оставшихся в один inactive pod" do
        create_list(:user, 7, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        inactive_pods = Pod.where(status: "inactive")
        expect(inactive_pods.count).to eq(1)
        expect(inactive_pods.first.users.count).to eq(2)
      end
    end

    context "AC-9: тайбрейкер по id" do
      it "при равном score выбирает пользователя с меньшим id" do
        anchor = nearby_user
        lower  = nearby_user
        higher = nearby_user
        create_list(:user, 3, latitude: 53.9, longitude: 27.5)

        MatchingService.run

        pod = Pod.joins(:pod_memberships)
                 .where(pod_memberships: { user_id: anchor.id })
                 .first
        expect(pod.users).to include(lower)
      end
    end

    context "AC-10: уведомления" do
      it "каждый участник получает Notification 'Вы вошли в группу'" do
        users = create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        users.each do |user|
          expect(user.notifications.pluck(:message)).to include("Вы вошли в группу")
        end
      end
    end

    context "AC-12: инварианты размера" do
      it "active pod всегда содержит ровно 5 участников" do
        create_list(:user, 10, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        Pod.where(status: "active").each do |pod|
          expect(pod.users.count).to eq(5)
        end
      end

      it "inactive pod содержит от 1 до 4 участников" do
        create_list(:user, 7, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        Pod.where(status: "inactive").each do |pod|
          expect(pod.users.count).to be_between(1, 4)
        end
      end
    end
  end
end
