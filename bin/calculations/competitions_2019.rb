# frozen_string_literal: true

COMPETITIONS = {
  # blind_date: {
  #   categories: [
  #     { name: "Category 1/2 Men" },
  #     { name: "Category 2/3 Men" },
  #     { name: "Category 3/4 Men" },
  #     { name: "Category 5 Men" },
  #     { name: "Junior Men 14-18" },
  #     { name: "Junior Men 9-13" },
  #     { name: "Junior Women 14-18" },
  #     { name: "Junior Women 9-13" },
  #     { name: "Masters Men 1/2 40+" },
  #     { name: "Masters Men 2/3 40+" },
  #     { name: "Masters Men 3/4 40+" },
  #     { name: "Masters Men 50+" },
  #     { name: "Masters Men 60+" },
  #     { name: "Singlespeed" },
  #     { name: "Stampede" },
  #     { name: "Women 1/2" },
  #     { name: "Women 3" },
  #     { name: "Women 4" },
  #     { name: "Women 5" }
  #   ],
  #   event_id: 26562,
  #   name: "Blind Date at the Dairy",
  #   rules: {
  #     maximum_events: -1,
  #     points_for_place: [15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  #   }
  # },
  # cross_crusade: {
  #   categories: [
  #     { name: "Athena" },
  #     { name: "Clydesdale" },
  #     { name: "Elite Junior Men" },
  #     { name: "Elite Junior Women", maximum_events: -2 },
  #     { name: "Junior Men 10-12" },
  #     { name: "Junior Men 13-14" },
  #     { name: "Junior Men 15-16" },
  #     { name: "Junior Men 17-18" },
  #     { name: "Junior Men 3/4/5" },
  #     { name: "Junior Men 9-12 3/4/5", reject: true },
  #     { name: "Junior Men 9" },
  #     { name: "Junior Women 10-12" },
  #     { name: "Junior Women 13-14" },
  #     { name: "Junior Women 15-16" },
  #     { name: "Junior Women 17-18" },
  #     { name: "Junior Women 3/4/5" },
  #     { name: "Junior Women 9-12 3/4/5", reject: true },
  #     { name: "Junior Women 9" },
  #     { name: "Masters 35+ 1/2" },
  #     { name: "Masters 35+ 3" },
  #     { name: "Masters 35+ 4" },
  #     { name: "Masters 50+" },
  #     { name: "Masters 60+" },
  #     { name: "Masters 70+" },
  #     { name: "Masters Women 35+ 1/2", maximum_events: -2 },
  #     { name: "Masters Women 35+ 3", maximum_events: -2 },
  #     { name: "Masters Women 50+", maximum_events: -2 },
  #     { name: "Masters Women 60+", maximum_events: -2 },
  #     { name: "Men 1/2" },
  #     { name: "Men 2/3" },
  #     { name: "Men 4" },
  #     { name: "Men 5" },
  #     { name: "Singlespeed Women" },
  #     { name: "Singlespeed" },
  #     { name: "Women 1/2" },
  #     { name: "Women 2/3", maximum_events: -2 },
  #     { name: "Women 4", maximum_events: -2 },
  #     { name: "Women 5", maximum_events: -2 }
  #   ],
  #   event_id: 26903,
  #   name: "River City Bicycles Cyclocross Crusade",
  #   rules: {
  #     maximum_events: -1,
  #     minimum_events: 3,
  #     points_for_place: [26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  #   }
  # },
  # cross_crusade_team_competition: {
  #   categories: [
  #     { name: "Junior Men 3/4/5", reject: true },
  #     { name: "Junior Women 3/4/5", reject: true }
  #   ],
  #   event_id: 26903,
  #   name: "River City Bicycles Cyclocross Crusade Team Competition",
  #   rules: {
  #     missing_result_penalty: 100,
  #     place_by: "fewest_points",
  #     points_for_place: (1..100).to_a,
  #     results_per_event: 10,
  #     team: true
  #   }
  # },
  # gplb: {
  #   categories: [
  #     { name: "Athena" },
  #     { name: "Category 1/2 35+ Men" },
  #     { name: "Category 1/2 35+ Women" },
  #     { name: "Category 1/2 Men" },
  #     { name: "Category 1/2 Women" },
  #     { name: "Category 2/3 Men" },
  #     { name: "Category 2/3 Women" },
  #     { name: "Category 3 35+ Men" },
  #     { name: "Category 3 35+ Women" },
  #     { name: "Category 3 Women" },
  #     { name: "Category 4 35+ Men" },
  #     { name: "Category 4 Men" },
  #     { name: "Category 4 Women" },
  #     { name: "Category 5 Men" },
  #     { name: "Category 5 Women" },
  #     { name: "Clydesdale" },
  #     { name: "Elite Junior Men" },
  #     { name: "Elite Junior Women" },
  #     { name: "Junior Men 13-14 3/4/5", reject: true },
  #     { name: "Junior Men 15-16 3/4/5", reject: true },
  #     { name: "Junior Men 17-18 3/4/5", reject: true },
  #     { name: "Junior Men 3/4/5" },
  #     { name: "Junior Men 9-12 3/4/5", reject: true },
  #     { name: "Junior Women 13-14 3/4/5", reject: true },
  #     { name: "Junior Women 15-16 3/4/5", reject: true },
  #     { name: "Junior Women 17-18 3/4/5", reject: true },
  #     { name: "Junior Women 3/4/5" },
  #     { name: "Junior Women 9-12 3/4/5", reject: true },
  #     { name: "Masters 50+ Men" },
  #     { name: "Masters 50+ Women" },
  #     { name: "Masters 60+ Men" },
  #     { name: "Masters 60+ Women" },
  #     { name: "Singlespeed Men" },
  #     { name: "Singlespeed Women" }
  #   ],
  #   event_id: 26874,
  #   name: "Gran Prix Luciano Bailey",
  #   rules: {
  #     maximum_events: -1,
  #     minimum_events: 4,
  #     points_for_place: [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  #   }
  # },
  # ironman: {
  #   name: "Ironman",
  #   rules: {
  #     members_only: true,
  #     points_for_place: 1
  #   }
  # },
  # oregon_cup: {
  #   categories: [
  #     { name: "Category 1/2 Men" }
  #   ],
  #   events: [
  #     { id: 26467, multiplier: 1 },
  #     { id: 26471, multiplier: 1 },
  #     { id: 26494, multiplier: 1 },
  #     { id: 26540, multiplier: 1 },
  #     { id: 26595, multiplier: 1 },
  #     { id: 26557, multiplier: 1 }
  #   ],
  #   name: "Oregon Cup",
  #   rules: {
  #     members_only: true,
  #     points_for_place: [100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10],
  #     specific_events: true
  #   }
  # },
  # owps: {
  #   categories: [
  #     { name: "Women 1/2" },
  #     { name: "Women 3" },
  #     { name: "Women 4" }
  #   ],
  #   events: [
  #     { id: 26467, multiplier: 1 },
  #     { id: 26494, multiplier: 1 },
  #     { id: 26524, multiplier: 1 },
  #     { id: 26540, multiplier: 1 },
  #     { id: 26833, multiplier: 1 },
  #     { id: 26446, multiplier: 1 }
  #   ],
  #   name: "Oregon Womens Prestige Series",
  #   rules: {
  #     members_only: true,
  #     points_for_place: [25, 21, 18, 16, 14, 12, 10, 8, 7, 6, 5, 4, 3, 2, 1],
  #     specific_events: true
  #   }
  # },
  # pdx_stxc: {
  #   categories: [
  #     { name: "Category 1 Men U45" },
  #     { name: "Category 1 Men 45+" },
  #     { name: "Category 2 Men 40-49" },
  #     { name: "Category 2 Men 50-59" },
  #     { name: "Category 2 Men 60+" },
  #     { name: "Category 2 Men U40" },
  #     { name: "Category 2 Women 45+" },
  #     { name: "Category 2 Women U45" },
  #     { name: "Category 3 Men 10-13" },
  #     { name: "Category 3 Men 14-18" },
  #     { name: "Category 3 Men 19-39" },
  #     { name: "Category 3 Men 40-49" },
  #     { name: "Category 3 Men 50+" },
  #     { name: "Category 3 Women 10-13" },
  #     { name: "Category 3 Women 14-18" },
  #     { name: "Category 3 Women 19+" },
  #     { name: "Clydesdale" },
  #     { name: "Elite Men" },
  #     { name: "Elite/Category 1 Women" },
  #     { name: "Singlespeed" }
  #   ],
  #   event_id: 26529,
  #   name: "Portland Short Track Series",
  #   rules: {
  #     maximum_events: -1,
  #     points_for_place: [
  #       100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14,
  #       13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
  #     ]
  #   }
  # },
  # pdx_stxc_june: {
  #   categories: [
  #     { name: "Category 1 Men U45" },
  #     { name: "Category 1 Men 45+" },
  #     { name: "Category 2 Men 40-49" },
  #     { name: "Category 2 Men 50-59" },
  #     { name: "Category 2 Men 60+" },
  #     { name: "Category 2 Men U40" },
  #     { name: "Category 2 Women 45+" },
  #     { name: "Category 2 Women U45" },
  #     { name: "Category 3 Men 10-13" },
  #     { name: "Category 3 Men 14-18" },
  #     { name: "Category 3 Men 19-39" },
  #     { name: "Category 3 Men 40-49" },
  #     { name: "Category 3 Men 50+" },
  #     { name: "Category 3 Women 10-13" },
  #     { name: "Category 3 Women 14-18" },
  #     { name: "Category 3 Women 19+" },
  #     { name: "Clydesdale" },
  #     { name: "Elite Men" },
  #     { name: "Elite/Category 1 Women" },
  #     { name: "Singlespeed" }
  #   ],
  #   name: "Portland Short Track Series: June",
  #   rules: {
  #     maximum_events: -1,
  #     points_for_place: [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
  #     specific_events: true
  #   },
  #   events: [
  #     { id: 26529, multiplier: 1 },
  #     { id: 26525, multiplier: 1 },
  #     { id: 26526, multiplier: 1 },
  #     { id: 26528, multiplier: 1 }
  #   ]
  # },
  # pdx_stxc_july: {
  #   categories: [
  #     { name: "Category 1 Men U45" },
  #     { name: "Category 1 Men 45+" },
  #     { name: "Category 2 Men 40-49" },
  #     { name: "Category 2 Men 50-59" },
  #     { name: "Category 2 Men 60+" },
  #     { name: "Category 2 Men U40" },
  #     { name: "Category 2 Women 45+" },
  #     { name: "Category 2 Women U45" },
  #     { name: "Category 3 Men 10-13" },
  #     { name: "Category 3 Men 14-18" },
  #     { name: "Category 3 Men 19-39" },
  #     { name: "Category 3 Men 40-49" },
  #     { name: "Category 3 Men 50+" },
  #     { name: "Category 3 Women 10-13" },
  #     { name: "Category 3 Women 14-18" },
  #     { name: "Category 3 Women 19+" },
  #     { name: "Clydesdale" },
  #     { name: "Elite Men" },
  #     { name: "Elite/Category 1 Women" },
  #     { name: "Singlespeed" }
  #   ],
  #   name: "Portland Short Track Series: July",
  #   rules: {
  #     maximum_events: -1,
  #     points_for_place: [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
  #     specific_events: true
  #   },
  #   events: [
  #     { id: 26531, multiplier: 1 },
  #     { id: 26532, multiplier: 1 },
  #     { id: 26533, multiplier: 1 },
  #     { id: 26534, multiplier: 1 }
  #   ]
  # },
  # tabor: {
  #   categories: [
  #     { name: "Senior Men" },
  #     { name: "Category 3 Men" },
  #     { name: "Category 4 Men" },
  #     { name: "Category 4/5 Women" },
  #     { name: "Category 5 Men" },
  #     { name: "Masters Men 50+" },
  #     { name: "Masters Men 40+" },
  #     { name: "Senior Women" }
  #   ],
  #   event_id: 26518,
  #   name: "Mt. Tabor Series",
  #   rules: {
  #     double_points_for_last_event: true,
  #     points_for_place: [100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11]
  #   }
  # },
  # portland_trophy_cup: {
  #   categories: [
  #     { name: "Junior Open" },
  #     { name: "Junior Women" },
  #     { name: "Open 1/2" },
  #     { name: "Open 3/4 35+" },
  #     { name: "Open 3/4" },
  #     { name: "Open 50+" },
  #     { name: "Open 60+" },
  #     { name: "Open Beginner" },
  #     { name: "Open Masters 1/2 35+" },
  #     { name: "Open Singlespeed" },
  #     { name: "Women 1/2" },
  #     { name: "Women 3/4" },
  #     { name: "Women Beginner" },
  #     { name: "Women Singlespeed" }
  #   ],
  #   event_id: 26868,
  #   name: "Portland Trophy Cup",
  #   rules: {
  #     double_points_for_last_event: true,
  #     points_for_place: [25, 20, 16, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 1]
  #   }
  # },
  age_graded_bar: {
    categories: [
      { name: "Junior Men 10-12" },
      { name: "Junior Men 13-14" },
      { name: "Junior Men 15-16" },
      { name: "Junior Men 17-18" },
      { name: "Junior Women 10-12" },
      { name: "Junior Women 13-14" },
      { name: "Junior Women 15-16" },
      { name: "Junior Women 17-18" },
      { name: "Masters Men 30-34" },
      { name: "Masters Men 35-39" },
      { name: "Masters Men 40-44" },
      { name: "Masters Men 45-49" },
      { name: "Masters Men 50-54" },
      { name: "Masters Men 55-59" },
      { name: "Masters Men 60-64" },
      { name: "Masters Men 65-69" },
      { name: "Masters Men 70+" },
      { name: "Masters Women 30-34" },
      { name: "Masters Women 35-39" },
      { name: "Masters Women 40-44" },
      { name: "Masters Women 45-49" },
      { name: "Masters Women 50-54" },
      { name: "Masters Women 55-59" },
      { name: "Masters Women 60+" }
    ],
    name: "Age-Graded BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Overall",
      group_by: "age", #???
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  criterium_bar: {
    categories: [
      { name: "Athena" },
      { name: "Clydesdale" },
      { name: "Category 3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Category 5 Women" },
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Men 4/5" },
      { name: "Masters Women" },
      { name: "Masters Women 4" },
      { name: "Category Pro/1/2 Men" },
      { name: "Category Pro/1/2 Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    events: [
      { id: 26833, multiplier: 2 },
      { id: 27089, multiplier: 1 },
      { id: 27089, multiplier: 1 },
      { id: 27046, multiplier: 1 }
    ],
    name: "Criterium BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Criterium",
      disciplines: ["Criterium"],
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  cyclocross_bar: {
    categories: [
      { name: "Athena" },
      { name: "Category Pro/1/2 Men" },
      { name: "Category Pro/1/2 Women" },
      { name: "Category 2/3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Category 5 Women" },
      { name: "Clydesdale" },
      { name: "Junior Men" },
      { name: "Junior Men 3/4/5", reject: true },
      { name: "Category 3/4/5 Junior Men", reject: true },
      { name: "Category 1/2/3 Junior Men", reject: true },
      { name: "Category 1/2/3/4/5 Junior Men", reject: true },
      { name: "Junior Women 3/4/5", reject: true },
      { name: "Junior Women 1/2/3", reject: true },
      { name: "Category 1/2/3 Junior Women", reject: true },
      { name: "Category 3/4/5 Junior Women", reject: true },
      { name: "Category 1/2/3/4/5 Junior Women", reject: true },
      { name: "Duchess of CX", reject: true },
      { name: "Duke of CX", reject: true },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    events: [
      { id: 26901, multiplier: 2 },
      { id: 27097, multiplier: 1 },
      { id: 27105, multiplier: 1 },
      { id: 27106, multiplier: 1 },
      { id: 27104, multiplier: 1 },
      { id: 27094, multiplier: 1 },
      { id: 27095, multiplier: 1 },
      { id: 27187, multiplier: 1 }
    ],
    name: "Cyclocross BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Cyclocross",
      disciplines: ["Cyclocross"],
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  gravel_bar: {
    categories: [
      { name: "Athena" },
      { name: "Category Pro/1/2 Men" },
      { name: "Category Pro/1/2 Women" },
      { name: "Category 2/3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Category 5 Women" },
      { name: "Clydesdale" },
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    name: "Gravel BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Gravel",
      disciplines: ["Gravel"],
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  mountain_bike_bar: {
    categories: [
      { name: "Athena" },
      { name: "Category 1 Men" },
      { name: "Category 1 Women" },
      { name: "Category 2 Men" },
      { name: "Category 2 Women" },
      { name: "Category 3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Category 5 Women" },
      { name: "Clydesdale" },
      { name: "Elite Men" },
      { name: "Elite Women" },
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    name: "Mountain Bike BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Mountain Bike",
      disciplines: ["Mountain Bike", "Downhill", "Super D"],
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  road_bar: {
    categories: [
      { name: "Athena" },
      { name: "Category 3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Category 5 Women" },
      { name: "Clydesdale" },
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Men 4/5" },
      { name: "Masters Women" },
      { name: "Masters Women 4" },
      { name: "Category Pro/1/2 Men" },
      { name: "Category Pro/1/2 Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    events: [
      { id: 26518, multiplier: 1 },
      { id: 26540, multiplier: 2 },
      { id: 26928, multiplier: 1 },
      { id: 26941, multiplier: 1 },
      { id: 26944, multiplier: 1 },
      { id: 26968, multiplier: 1 },
      { id: 27013, multiplier: 1 },
      { id: 27017, multiplier: 1 },
      { id: 27058, multiplier: 1 },
      { id: 27083, multiplier: 1 }
    ],
    name: "Road BAR",
    rules: {
      association_sanctioned_only: true,
      disciplines: %w[Circuit Road],
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  short_track_bar: {
    categories: [
      { name: "Athena" },
      { name: "Category 1 Men" },
      { name: "Category 1 Women" },
      { name: "Category 2 Men" },
      { name: "Category 2 Women" },
      { name: "Category 3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Category 5 Women" },
      { name: "Clydesdale" },
      { name: "Elite Men" },
      { name: "Elite Women" },
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    events: [
      { id: 26979, multiplier: 1 },
      { id: 26980, multiplier: 1 }
    ],
    name: "Short Track BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Short Track",
      disciplines: ["Short Track"],
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  time_trial_bar: {
    categories: [
      { name: "Athena" },
      { name: "Category 3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Clydesdale" },
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Men 4/5" },
      { name: "Masters Women" },
      { name: "Masters Women 4" },
      { name: "Category Pro/1/2 Men" },
      { name: "Category Pro/1/2 Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    events: [
      { id: 26663, multiplier: 2 },
      { id: 27015, multiplier: 1 },
      { id: 27014, multiplier: 1 },
      { id: 27033, multiplier: 1 }
    ],
    name: "Time Trial BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Time Trial",
      disciplines: ["Time Trial"],
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  track_bar: {
    categories: [
      { name: "Athena" },
      { name: "Category 3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Clydesdale" },
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Men 4/5" },
      { name: "Masters Women" },
      { name: "Masters Women 4" },
      { name: "Category Pro/1/2 Men" },
      { name: "Category Pro/1/2 Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    events: [
      { id: 26974, multiplier: 2 },
      { id: 26975, multiplier: 2 },
      { id: 26976, multiplier: 2 },
      { id: 27031, multiplier: 1 },
      { id: 27032, multiplier: 1 },
      { id: 27037, multiplier: 1 },
      { id: 27038, multiplier: 1 },
      { id: 27055, multiplier: 1 },
      { id: 27056, multiplier: 1 },
      { id: 27057, multiplier: 1 },
      { id: 27065, multiplier: 1 },
      { id: 27070, multiplier: 1 }
    ],
    name: "Track BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Track",
      disciplines: ["Track"],
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  overall_bar: {
    categories: [
      { name: "Athena" },
      { name: "Category 3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Category 5 Women" },
      { name: "Clydesdale" },
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Women" },
      { name: "Category Pro/1/2 Men" },
      { name: "Category Pro/1/2 Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    name: "Overall BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Overall",
      maximum_events: -3,
      members_only: true,
      points_for_place: (1..300).to_a.reverse,
      source_event_keys: %w[criterium_bar cyclocross_bar gravel_bar mountain_bike_bar road_bar short_track_bar time_trial_bar track_bar],
      weekday_events: true
    }
  },
  team_bar: {
    name: "Team BAR",
    events: [
      { id: 26518, multiplier: 1 },
      { id: 26540, multiplier: 1 },
      { id: 26540, multiplier: 2 },
      { id: 26663, multiplier: 1 },
      { id: 26663, multiplier: 2 },
      { id: 26833, multiplier: 1 },
      { id: 26833, multiplier: 2 },
      { id: 26901, multiplier: 1 },
      { id: 26901, multiplier: 2 },
      { id: 26928, multiplier: 1 },
      { id: 26941, multiplier: 1 },
      { id: 26944, multiplier: 1 },
      { id: 26974, multiplier: 1 },
      { id: 26974, multiplier: 2 },
      { id: 26975, multiplier: 1 },
      { id: 26975, multiplier: 2 },
      { id: 26976, multiplier: 1 },
      { id: 26976, multiplier: 2 },
      { id: 26979, multiplier: 1 },
      { id: 26980, multiplier: 1 },
      { id: 27013, multiplier: 1 },
      { id: 27014, multiplier: 1 },
      { id: 27015, multiplier: 1 },
      { id: 27017, multiplier: 1 },
      { id: 27031, multiplier: 1 },
      { id: 27032, multiplier: 1 },
      { id: 27033, multiplier: 1 },
      { id: 27037, multiplier: 1 },
      { id: 27038, multiplier: 1 },
      { id: 27046, multiplier: 1 },
      { id: 27055, multiplier: 1 },
      { id: 27056, multiplier: 1 },
      { id: 27057, multiplier: 1 },
      { id: 27058, multiplier: 1 },
      { id: 27065, multiplier: 1 },
      { id: 27070, multiplier: 1 },
      { id: 27083, multiplier: 1 },
      { id: 27089, multiplier: 1 },
      { id: 27094, multiplier: 1 },
      { id: 27095, multiplier: 1 },
      { id: 27097, multiplier: 1 },
      { id: 27104, multiplier: 1 },
      { id: 27105, multiplier: 1 },
      { id: 27106, multiplier: 1 },
      { id: 27187, multiplier: 1 }
    ],
    rules: {
      association_sanctioned_only: true,
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      team: true,
      weekday_events: false
    }
  }
}.freeze
