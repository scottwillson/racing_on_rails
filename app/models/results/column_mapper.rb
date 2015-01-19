module Results
  MAP = {
    :"#"                 => :number,
    :"bib_#"             => :number,
    :"cat."              => :category_name,
    :"club/team"         => :team_name,
    :"license_#"         => :license,
    :"membership_#"      => :license,
    :"rider_#"           => :number,
    :"team/club"         => :team_name,
    :"wsba#"             => :number,
    :bar_category        => :parent,
    :barcategory         => :parent,
    :bib                 => :number,
    :bonus               => :time_bonus_penalty,
    :categories          => :category_name,
    :category            => :category_name,
    :"category.name"     => :category_name,
    :class               => :category_class,
    :delta_time          => :time_gap_to_leader,
    :down                => :time_gap_to_leader,
    :first               => :first_name,
    :firstname           => :first_name,
    :gap                 => :time_gap_to_leader,
    :hometown            => :city,
    :lane                => :category_name,
    :last                => :last_name,
    :lastname            => :last_name,
    :membership          => :license,
    :obra_number         => :number,
    :oregoncup           => :oregon_cup,
    :penalty             => :time_bonus_penalty,
    :person              => :name,
    :"person.first_name" => :first_name,
    :"person.last_name"  => :last_name,
    :pl                  => :place,
    :placing             => :place,
    :pts                 => :points,
    :race_category       => :category_name,
    :racing_age          => :age,
    :sex                 => :gender,
    :st                  => :time,
    :"stage_+_penalty"   => :time_total,
    :stage_time          => :time,
    :stop_time           => :time,
    :team                => :team_name,
    :"team.name"         => :team_name,
    :time                => :time,
    :time_total          => :time_total,
    :total_points        => :points_total,
    :total_time          => :time_total
  }

  class ColumnMapper < Tabular::ColumnMapper
    def map(key)
      return nil if is_blank?(key)

      key = symbolize(key)

      MAP[key] || key
    end
  end
end
