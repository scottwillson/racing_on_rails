if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

