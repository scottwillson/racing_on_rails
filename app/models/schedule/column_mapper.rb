module Schedule
  class ColumnMapper < Tabular::ColumnMapper
    MAP = {
      race_name: :name,
      race: :name,
      event: :name,
      type: :discipline,
      city_state: :location,
      promoter: :promoter_name,
      phone: :promoter_phone,
      email: :promoter_email,
      sponsoring_team: :team_id,
      team: :team_id,
      club: :team_id,
      website: :flyer,
      where: :city,
      flyer_approved?: :flyer_approved,
      velodrome: :velodrome_name
    }

    def map(key)
      return nil if is_blank?(key)
      key = symbolize(key)
      MAP[key] || key
    end
  end
end
