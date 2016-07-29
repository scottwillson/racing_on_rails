Race.where(event_id: 24520).update_all(distance: 11.2)
Race.where(event_id: 24649).update_all(distance: 22.8)
Race.where(id: [ 576807, 576808, 576809, 576810, 576811, 576812, 576813, 576814 ]).update_all(distance: 13.8)
Race.where(event_id: 24558).update_all(distance: 22.8)
Race.where(id: [576423]).update_all(distance: 6.8)
Race.where(id: [576425, 576427, 576428, 576429, 576430, 576432, 578250]).update_all(distance: 13.8)
Race.where(event_id: 24580).update_all(distance: 5.5)
Result.find(31597641).destroy!
