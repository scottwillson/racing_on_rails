# MultiDayEvent with events on several, non-contiguous days
#
# This class doesn't add any special behavior to MultiDayEvent, but it is
# convential to separate events like stage races from series like the
# Cross Crusade
class Series < MultiDayEvent
end
