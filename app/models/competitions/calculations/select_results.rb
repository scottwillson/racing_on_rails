# frozen_string_literal: true

module Competitions::Calculations::SelectResults
  # Apply rules. Example: DNS or numeric place? Person is a member for this year?
  # It's somewhat arbritrary which elgilibilty rules are applied here, and which were applied by
  # the calling Competition when it selected results from the database.
  # Only keep best +results_per_event+ results for participant (person or team).
  def select_results(results, rules)
    results = results.select { |r| r.participant_id && [nil, "", "DQ", "DNS"].exclude?(r.place) }
    results = reject_dnfs(results, rules)
    results = select_members(results, rules)
    results = select_in_source_events(results, rules)
    results = reject_upgrade_only(results)
    results = select_results_for(:event_id, results, rules[:results_per_event], rules[:use_source_result_points])
    results = select_results_for(:race_id, results, rules[:results_per_race], rules[:use_source_result_points])
    select_results_for_minimum_events results, rules
  end

  def reject_dnfs(results, rules)
    if rules[:dnf_points].nil? || rules[:dnf_points] == 0
      results.reject { |r| r.place == "DNF" }
    else
      results
    end
  end

  def select_members(results, rules)
    if rules[:members_only]
      results.select { |r| member_in_year?(r, rules[:team]) }
    else
      results
    end
  end

  def select_in_source_events(results, rules)
    if rules[:source_event_ids]
      results.select { |r| r.upgrade || rules[:source_event_ids].include?(r.event_id) }
    else
      results
    end
  end

  # If participant's results are all upgrade results from a lower category,
  # remove their results
  def reject_upgrade_only(results)
    results.group_by(&:participant_id)
           .map do |_participant_id, participant_results|
      if participant_results.all?(&:upgrade)
        []
      else
        participant_results
      end
    end
           .flatten
  end

  def select_results_for(field, results, limit, use_source_result_points)
    if limit == Competitions::Calculations::Calculator::UNLIMITED
      results
    else
      results.group_by { |r| [r.participant_id, r[field]] }
             .map do |_key, r|
        if use_source_result_points
          r.sort_by(&:points).reverse.take(limit)
        else
          r.sort_by { |r2| numeric_place(r2) }.take(limit)
        end
      end
             .flatten
    end
  end

  def member_in_year?(result, team = false)
    raise(ArgumentError, "Result year required to check membership") unless result.year

    if team
      result.team_member
    else
      result.member_from &&
        result.member_to &&
        result.member_from.year <= result.year &&
        result.member_to.year >= result.year
    end
  end

  def select_results_for_minimum_events(results, rules)
    return results if rules[:minimum_events].nil? || !event_complete?(rules)

    results
      .group_by(&:participant_id)
      .select do |_, participant_results|
      participant_results.size >= rules[:minimum_events]
    end
      .values
      .flatten
  end
end
