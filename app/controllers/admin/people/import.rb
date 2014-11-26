module Admin
  module People
    module Import
      extend ActiveSupport::Concern

      # Preview contents of new members file from event registration service website like SignMeUp or Active.com.
      def preview_import
        if params[:people_file].blank?
          flash[:warn] = "Choose a file of people to import first"
          return redirect_to(action: :index)
        end

        ActiveSupport::Notifications.instrument "preview_import.people.admin.racing_on_rails", original_filename: params[:people_file].original_filename

        path = "#{Dir.tmpdir}/#{params[:people_file].original_filename}"
        File.open(path, "wb") do |f|
          f.print(params[:people_file].read)
        end

        @people_file = PeopleFile.new(path)
        if @people_file
          assign_years_for_people_file
          session[:people_file_path] = temp_file.path
        else
          redirect_to :index
        end

        render "preview_import"
      end

      # See http://racingonrails.rocketsurgeryllc.com/sample_import_files/ for format details and examples.
      def import
        if params[:commit] == 'Cancel'
          session[:people_file_path] = nil
          redirect_to(action: 'index')

        elsif params[:commit] == 'Import'
          ActiveSupport::Notifications.instrument "import.people.admin.racing_on_rails", people_file_path: session[:people_file_path]

          Duplicate.delete_all
          path = session[:people_file_path]
          if path.blank?
            flash[:warn] = "No import file"
            return redirect_to(admin_people_path)
          end

          people_file = PeopleFile.new(path)
          people_file.import(params[:update_membership], params[:year])
          flash[:notice] = "Imported #{pluralize(people_file.created, 'new person')} and updated #{pluralize(people_file.updated, 'existing person')}"
          session[:people_file_path] = nil
          if people_file.duplicates.empty?
            redirect_to admin_people_path
          else
            flash[:warn] = 'Some names in the import file already exist more than once. Match with an existing person or create a new person with the same name.'
            redirect_to duplicates_admin_people_path
          end
          expire_cache

        else
          raise "Expected 'Import' or 'Cancel'"
        end
      end

      # Unresolved duplicates after import
      def duplicates
        @duplicates = Duplicate.all
        ActiveSupport::Notifications.instrument "duplicates.people.admin.racing_on_rails", duplicates: @duplicates.size

        @duplicates = sort_duplicates(@duplicates)

        @duplicates.each do |duplicate|
          ActiveSupport::Notifications.instrument "duplicate.people.admin.racing_on_rails", person_name: duplicate.person.name, person_id: duplicate.person.id, people_ids: duplicate.people.map(&:id)
        end
      end

      def resolve_duplicates
        @duplicates = Duplicate.all
        @duplicates.each do |duplicate|
          id = params[duplicate.to_param]
          if id == 'new'
            ActiveSupport::Notifications.instrument "resolve_duplicates.people.admin.racing_on_rails", resolution: :new, person_name: duplicate.person.name, person_id: duplicate.person.id
            duplicate.person.save!
          elsif id.present?
            ActiveSupport::Notifications.instrument "resolve_duplicates.people.admin.racing_on_rails", resolution: :update, person_name: duplicate.person.name, person_id: id, new_attributes: duplicate.new_attributes
            person = Person.update(id, duplicate.new_attributes)
            unless person.valid?
              raise ActiveRecord::RecordNotSaved.new(person.errors.full_messages.join(', '))
            end
          end
        end

        Duplicate.delete_all
        redirect_to(action: 'index')
      end


      private

      def assign_years_for_people_file
        date = current_date
        if date.month == 12
          @year = date.year + 1
        else
          @year = date.year
        end
        @years = [ date.year, date.year + 1 ]
      end

      def sort_duplicates(duplicates)
        duplicates.sort do |x, y|
          diff = (x.person.last_name || '') <=> y.person.last_name
          if diff == 0
            (x.person.first_name || '') <=> y.person.first_name
          else
            diff
          end
        end
      end
    end
  end
end
