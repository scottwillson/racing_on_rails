# Latest OS X is busted
if BigDecimal("10.03").to_f != 10.03
 class BigDecimal
   def to_f
     self.to_s.to_f
   end
 end
end
