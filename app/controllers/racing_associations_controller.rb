# frozen_string_literal: true

class RacingAssociationsController < Admin::AdminController
  def edit
    @racing_association = RacingAssociation.find(params[:id])
  end

  def update
    @racing_association = RacingAssociation.find(params[:id])
    if @racing_association.update(racing_association_params)
      flash[:notice] = "Updated #{@racing_association.name}"
      redirect_to edit_racing_association_path(@racing_association)
    else
      render :edit
    end
  end

  protected

  def assign_current_admin_tab
    @current_admin_tab = "Site"
  end

  private

  def racing_association_params
    params_without_mobile.require(:racing_association).permit(
      :add_members_from_results,
      :administrator_tabs,
      :allow_iframes,
      :always_insert_table_headers,
      :award_cat4_participation_points,
      :bmx_numbers,
      :card_background_color,
      :card_text_color,
      :competitions,
      :country_code,
      :cx_memberships,
      :default_discipline,
      :payment_gateway_name,
      :default_region_id,
      :default_sanctioned_by,
      :eager_match_on_license,
      :email,
      :exempt_team_categories,
      :filter_schedule_by_region,
      :filter_schedule_by_sanctioning_organization,
      :flyers_in_new_window,
      :gender_specific_numbers,
      :include_multiday_events_on_schedule,
      :masters_age,
      :membership_email,
      :mobile_site,
      :name,
      :next_year_start_at,
      :rails_host,
      :rental_numbers_end,
      :rental_numbers_start,
      :result_questions_url,
      :sanctioning_organizations,
      :short_name,
      :show_all_teams_on_public_page,
      :show_calendar_view,
      :show_events_sanctioning_org_event_id,
      :show_events_velodrome,
      :show_license,
      :show_only_association_sanctioned_races_on_calendar,
      :show_practices_on_calendar,
      :ssl,
      :state,
      :static_host,
      :unregistered_teams_in_results,
      :usac_region,
      :usac_results_format
    )
  end
end
