class MatchingService
  RADII_KM            = [5, 10, 15, 20, 25, 30].freeze
  MIN_POD_SIZE        = 5
  SCORE_THRESHOLD     = 3
  POD_CANDIDATE_COUNT = 4

  SIMPLE_FIELDS = %i[life_phase social_style friendship_goal
                     openness_level social_frequency].freeze

  def self.run = new.run

  def run
    pool = User.matching_pool.to_a
    return "Not enough users to form a pod." if pool.size < MIN_POD_SIZE

    until pool.size < MIN_POD_SIZE
      anchor     = pool.shift
      candidates = find_candidates(anchor, pool)
      members    = [anchor] + candidates
      status     = candidates.size >= POD_CANDIDATE_COUNT ? "active" : "inactive"

      create_pod(members, status)
      pool -= members
    end

    create_pod(pool, "inactive") unless pool.empty?
  end

  private

  def find_candidates(anchor, pool)
    RADII_KM.each do |radius|
      within = pool.select { |u| haversine(anchor, u) <= radius }
      scored = within
        .map    { |u| [u, compatibility_score(anchor, u)] }
        .select { |_, s| s >= SCORE_THRESHOLD }
        .sort_by { |u, s| [-s, u.id] }

      return scored.first(POD_CANDIDATE_COUNT).map(&:first) if scored.size >= POD_CANDIDATE_COUNT
    end

    pool
      .select { |u| haversine(anchor, u) <= RADII_KM.last }
      .map    { |u| [u, compatibility_score(anchor, u)] }
      .select { |_, s| s >= SCORE_THRESHOLD }
      .sort_by { |u, s| [-s, u.id] }
      .first(POD_CANDIDATE_COUNT)
      .map(&:first)
  end

  def compatibility_score(a, b)
    score = SIMPLE_FIELDS.sum do |field|
      val_a = a.public_send(field)
      val_b = b.public_send(field)
      val_a && val_b && val_a == val_b ? 1 : 0
    end
    score + schedule_score(a.schedule_preference, b.schedule_preference)
  end

  def schedule_score(sp_a, sp_b)
    a = (sp_a || {}).transform_keys(&:to_s)
    b = (sp_b || {}).transform_keys(&:to_s)
    n = (a.keys & b.keys).size
    return 0 if n == 0
    1 + (n - 1) * 0.2
  end

  def haversine(u1, u2)
    rad = Math::PI / 180
    dlat = (u2.latitude  - u1.latitude)  * rad
    dlon = (u2.longitude - u1.longitude) * rad
    lat1 = u1.latitude * rad
    lat2 = u2.latitude * rad
    a = Math.sin(dlat / 2)**2 +
        Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon / 2)**2
    6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end

  def create_pod(members, status)
    pod = Pod.create!(status: status)
    members.each do |user|
      PodMembership.create!(pod: pod, user: user)
      Notification.create!(user: user, pod: pod, message: "Вы вошли в группу", read: false)
    end
  end
end
