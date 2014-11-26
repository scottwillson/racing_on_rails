module Results
  module CreateIfBestResultForRaceExtension
    def create_if_best_result_for_race(attributes)
      source_result = attributes[:source_result]
      scores = proxy_association.owner.scores

      scores.each do |score|
        if same_race?(score, source_result) && same_person?(score, source_result)
          if attributes[:points] > score.points
            scores.delete score
          else
            return nil
          end
        end
      end

      create attributes
    end

    def same_race?(score, result)
      score.source_result.person &&
      score.source_result.race_id  == result.race_id
    end

    def same_person?(score, result)
      score.source_result.person_id == result.person_id
    end
  end
end
