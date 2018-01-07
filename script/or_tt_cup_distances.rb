# frozen_string_literal: true

Race.where(event_id: 24_520).update_all(distance: 11.2)
Race.where(event_id: 24_649).update_all(distance: 22.8)
Race.where(id: [576_807, 576_808, 576_809, 576_810, 576_811, 576_812, 576_813, 576_814]).update_all(distance: 13.8)
Race.where(event_id: 24_558).update_all(distance: 22.8)
Race.where(id: [576_423]).update_all(distance: 6.8)
Race.where(id: [576_425, 576_427, 576_428, 576_429, 576_430, 576_432, 578_250]).update_all(distance: 13.8)
Race.where(event_id: 24_580).update_all(distance: 5.5)
Result.find(31_597_641).destroy!
