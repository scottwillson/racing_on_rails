class DefaultTeamOnPublicPageToTrue < ActiveRecord::Migration
  def up
    Team.update_all(show_on_public_page: true)
    change_column_default :teams, :show_on_public_page, true
  end

  def down
    change_column_default :teams, :show_on_public_page, false
  end
end