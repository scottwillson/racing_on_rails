class Page < ActiveRecord::Base
  acts_as_tree
  acts_as_versioned :version_column => "lock_version"
  before_validation :set_slug, :set_path, :set_author, :set_body
  validates_uniqueness_of :path
  validates_presence_of :author
  
  belongs_to :author, :class_name => "Person"
  
  after_create :update_parent
  after_destroy :update_parent

  def set_slug
    self.slug = self.title.downcase.gsub(" ", "_") if slug.blank?
  end
  
  def set_path
    # Ouch
    _ancestors = ancestors.reverse
    _ancestors.delete(self.parent)
    _ancestors << Page.find(self.parent_id) if self.parent_id
    
    self.path = (_ancestors << self).map(&:slug).join("/").gsub(/^\//, "")
  end
  
  def set_author
    # Yeah, yeah, a big side-effect.
    unless self.author_id
      system_person = Person.find_by_name("System")
      password = rand.to_s
      unless system_person
        system_person = Person.create!(:name => "System")
      end
      self.author = system_person
    end
  end
  
  # Can't reliably set default value for MySQL text field
  def set_body
    self.body = "" unless self.body
  end
  
  def update_parent
    if parent(true)
      parent.without_revision do
        parent.update_attribute(:updated_at, Time.now)
      end
    end
  end

  def valid_parents
    Page.find(:all).delete_if { |page|
      page == self || descendants.include?(page)
    }
  end
  
  def version
    self.lock_version
  end

  def to_s
    "#<Page #{id} #{title} #{slug} #{path}>"
  end
end
