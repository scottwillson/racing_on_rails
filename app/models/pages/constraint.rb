module Pages
	class Constraint
	  def matches?(request)
      Page.exists? path: Page.normalize_path(request.path)
	  end
	end
end
