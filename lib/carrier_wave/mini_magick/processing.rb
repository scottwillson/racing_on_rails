module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end

    def interlace
      manipulate! do |img|
        img.interlace "Plane"
        img
      end
    end
  end
end
