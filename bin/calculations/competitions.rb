# frozen_string_literal: true

COMPETITIONS = {
  blind_date: {
    categories: [
      { name: "Category 1/2 Men" },
      { name: "Category 2/3 Men" },
      { name: "Category 3/4 Men" },
      { name: "Category 5 Men" },
      { name: "Junior Men 14-18" },
      { name: "Junior Men 9-13" },
      { name: "Junior Women 14-18" },
      { name: "Junior Women 9-13" },
      { name: "Masters Men 1/2 40+" },
      { name: "Masters Men 2/3 40+" },
      { name: "Masters Men 3/4 40+" },
      { name: "Masters Men 50+" },
      { name: "Masters Men 60+" },
      { name: "Singlespeed" },
      { name: "Stampede" },
      { name: "Women 1/2" },
      { name: "Women 3" },
      { name: "Women 4" },
      { name: "Women 5" }
    ],
    competition_id: 26_417,
    event_id: 26_208,
    name: "Blind Date at the Dairy",
    rules: {
      maximum_events: -1,
      points_for_place: [15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    }
  },
  cross_crusade: {
    categories: [
      { name: "Athena" },
      { name: "Clydesdale" },
      { name: "Elite Junior Men" },
      { name: "Elite Junior Women", maximum_events: -2 },
      { name: "Junior Men 10-12" },
      { name: "Junior Men 13-14" },
      { name: "Junior Men 15-16" },
      { name: "Junior Men 17-18" },
      { name: "Junior Men 3/4/5" },
      { name: "Junior Men 9-12 3/4/5", reject: true },
      { name: "Junior Men 9" },
      { name: "Junior Women 10-12" },
      { name: "Junior Women 13-14" },
      { name: "Junior Women 15-16" },
      { name: "Junior Women 17-18" },
      { name: "Junior Women 3/4/5" },
      { name: "Junior Women 9-12 3/4/5", reject: true },
      { name: "Junior Women 9" },
      { name: "Masters 35+ 1/2" },
      { name: "Masters 35+ 3" },
      { name: "Masters 35+ 4" },
      { name: "Masters 50+" },
      { name: "Masters 60+" },
      { name: "Masters 70+" },
      { name: "Masters Women 35+ 1/2", maximum_events: -2 },
      { name: "Masters Women 35+ 3", maximum_events: -2 },
      { name: "Masters Women 50+", maximum_events: -2 },
      { name: "Masters Women 60+", maximum_events: -2 },
      { name: "Men 1/2" },
      { name: "Men 2/3" },
      { name: "Men 4" },
      { name: "Men 5" },
      { name: "Singlespeed Women" },
      { name: "Singlespeed" },
      { name: "Women 1/2" },
      { name: "Women 2/3", maximum_events: -2 },
      { name: "Women 4", maximum_events: -2 },
      { name: "Women 5", maximum_events: -2 }
    ],
    competition_id: 26_440,
    event_id: 25_896,
    name: "River City Bicycles Cyclocross Crusade",
    rules: {
      maximum_events: -1,
      minimum_events: 3,
      points_for_place: [26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    }
  },
  cross_crusade_team_competition: {
    categories: [
      { name: "Junior Men 3/4/5", reject: true },
      { name: "Junior Women 3/4/5", reject: true }
    ],
    competition_id: 26_441,
    event_id: 25_896,
    name: "River City Bicycles Cyclocross Crusade Team Competition",
    rules: {
      missing_result_penalty: 100,
      place_by: "fewest_points",
      points_for_place: (1..100).to_a,
      results_per_event: 10,
      team: true
    }
  },
  gpcd: {
    categories: [
      { name: "Athena" },
      { name: "Category 1/2 35+ Men" },
      { name: "Category 1/2 35+ Women" },
      { name: "Category 1/2 Men" },
      { name: "Category 1/2 Women" },
      { name: "Category 2/3 Men" },
      { name: "Category 2/3 Women" },
      { name: "Category 3 35+ Men" },
      { name: "Category 3 35+ Women" },
      { name: "Category 3 Women" },
      { name: "Category 4 35+ Men" },
      { name: "Category 4 Men" },
      { name: "Category 4 Women" },
      { name: "Category 5 Men" },
      { name: "Category 5 Women" },
      { name: "Clydesdale" },
      { name: "Elite Junior Men" },
      { name: "Elite Junior Women" },
      { name: "Junior Men 13-14 3/4/5", reject: true },
      { name: "Junior Men 15-16 3/4/5", reject: true },
      { name: "Junior Men 17-18 3/4/5", reject: true },
      { name: "Junior Men 3/4/5" },
      { name: "Junior Men 9-12 3/4/5", reject: true },
      { name: "Junior Women 13-14 3/4/5", reject: true },
      { name: "Junior Women 15-16 3/4/5", reject: true },
      { name: "Junior Women 17-18 3/4/5", reject: true },
      { name: "Junior Women 3/4/5" },
      { name: "Junior Women 9-12 3/4/5", reject: true },
      { name: "Masters 50+ Men" },
      { name: "Masters 50+ Women" },
      { name: "Masters 60+ Men" },
      { name: "Masters 60+ Women" },
      { name: "Singlespeed Men" },
      { name: "Singlespeed Women" }
    ],
    competition_id: 26_421,
    event_id: 26_278,
    name: "Gran Prix Carl Decker",
    rules: {
      maximum_events: -1,
      minimum_events: 4,
      points_for_place: [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    }
  },
  gpcd_david_douglas_by_age: {
    categories: [
      { name: "Junior Men 3/4/5", reject: true },
      { name: "Junior Women 3/4/5", reject: true },
      { name: "Men 9-18" },
      { name: "Men 19-34" },
      { name: "Men 35-49" },
      { name: "Men 50+" },
      { name: "Women 9-18" },
      { name: "Women 19-34" },
      { name: "Women 35-49" },
      { name: "Women 50+" }
    ],
    events: [
      { id: 26_276, multiplier: 1 }
    ],
    name: "Grand Prix Carl Decker: David Douglas Age Groups",
    rules: {
      group_by: "age",
      place_by: "place",
      specific_events: true
    }
  },
  gpcd_het_meer_by_age: {
    categories: [
      { name: "Junior Men 3/4/5", reject: true },
      { name: "Junior Women 3/4/5", reject: true },
      { name: "Men 9-18" },
      { name: "Men 19-34" },
      { name: "Men 35-49" },
      { name: "Men 50+" },
      { name: "Women 9-18" },
      { name: "Women 19-34" },
      { name: "Women 35-49" },
      { name: "Women 50+" }
    ],
    events: [
      { id: 26_277, multiplier: 1 }
    ],
    name: "Grand Prix Carl Decker: Het Meer Age Groups",
    rules: {
      group_by: "age",
      place_by: "place",
      specific_events: true
    }
  },
  gpcd_zaaldercross_by_age: {
    categories: [
      { name: "Junior Men 3/4/5", reject: true },
      { name: "Junior Women 3/4/5", reject: true },
      { name: "Men 9-18" },
      { name: "Men 19-34" },
      { name: "Men 35-49" },
      { name: "Men 50+" },
      { name: "Women 9-18" },
      { name: "Women 19-34" },
      { name: "Women 35-49" },
      { name: "Women 50+" }
    ],
    events: [
      { id: 26_279, multiplier: 1 }
    ],
    name: "Grand Prix Carl Decker: Zaaldercross Age Groups",
    rules: {
      group_by: "age",
      place_by: "place",
      specific_events: true
    }
  },
  gpcd_ninkrossi_by_age: {
    categories: [
      { name: "Junior Men 3/4/5", reject: true },
      { name: "Junior Women 3/4/5", reject: true },
      { name: "Men 9-18" },
      { name: "Men 19-34" },
      { name: "Men 35-49" },
      { name: "Men 50+" },
      { name: "Women 9-18" },
      { name: "Women 19-34" },
      { name: "Women 35-49" },
      { name: "Women 50+" }
    ],
    events: [
      { id: 26_280, multiplier: 1 }
    ],
    name: "Grand Prix Carl Decker: Ninkrossi Age Groups",
    rules: {
      group_by: "age",
      place_by: "place",
      specific_events: true
    }
  },
  gpcd_heiser_farm_by_age: {
    categories: [
      { name: "Junior Men 3/4/5", reject: true },
      { name: "Junior Women 3/4/5", reject: true },
      { name: "Men 9-18" },
      { name: "Men 19-34" },
      { name: "Men 35-49" },
      { name: "Men 50+" },
      { name: "Women 9-18" },
      { name: "Women 19-34" },
      { name: "Women 35-49" },
      { name: "Women 50+" }
    ],
    events: [
      { id: 26_281, multiplier: 1 }
    ],
    name: "Grand Prix Carl Decker: Heiser Farm Age Groups",
    rules: {
      group_by: "age",
      place_by: "place",
      specific_events: true
    }
  },
  gpcd_team: {
    name: "Grand Prix Carl Decker: Team Standings",
    rules: {
      results_per_event: 10,
      source_event_keys: %i[
        gpcd_david_douglas_by_age
        gpcd_het_meer_by_age
        gpcd_ninkrossi_by_age
        gpcd_heiser_farm_by_age
        gpcd_zaaldercross_by_age
      ],
      team: true
    }
  },
  ironman: {
    competition_id: 25_814,
    expect: [25813, 25844, 25868, 25869, 25875, 25876, 25879, 25880, 25884, 25885, 25897, 25898, 25900, 25902, 25903, 25904, 25915, 25916, 25917, 25918, 25920, 25921, 25922, 25923, 25925, 25926, 25927, 25929, 25930, 25931, 25933, 25934, 25935, 25936, 25937, 25938, 25939, 25942, 25943, 25944, 25946, 25950, 25951, 25952, 25953, 25956, 25957, 25958, 25959, 25960, 25961, 25962, 25963, 25964, 25966, 25967, 25969, 25970, 25971, 25972, 25973, 25974, 25976, 25977, 25978, 25979, 25980, 25982, 25984, 25986, 25987, 25988, 25991, 25992, 25993, 25994, 25995, 25998, 26002, 26008, 26010, 26011, 26012, 26013, 26014, 26015, 26016, 26017, 26018, 26019, 26020, 26021, 26022, 26023, 26025, 26026, 26028, 26029, 26030, 26033, 26034, 26037, 26038, 26039, 26040, 26041, 26043, 26044, 26045, 26047, 26048, 26050, 26051, 26052, 26053, 26054, 26055, 26057, 26058, 26059, 26060, 26061, 26062, 26064, 26065, 26066, 26067, 26068, 26069, 26070, 26071, 26073, 26074, 26075, 26084, 26085, 26087, 26088, 26090, 26093, 26095, 26096, 26097, 26098, 26099, 26100, 26101, 26103, 26104, 26114, 26115, 26117, 26118, 26119, 26120, 26121, 26123, 26124, 26125, 26126, 26127, 26128, 26130, 26137, 26139, 26140, 26141, 26142, 26143, 26147, 26149, 26150, 26152, 26154, 26156, 26160, 26162, 26164, 26165, 26166, 26168, 26170, 26171, 26173, 26174, 26175, 26176, 26178, 26179, 26183, 26186, 26187, 26188, 26189, 26192, 26193, 26194, 26195, 26196, 26197, 26198, 26199, 26206, 26207, 26209, 26210, 26211, 26212, 26235, 26236, 26237, 26238, 26239, 26250, 26251, 26252, 26254, 26255, 26257, 26262, 26276, 26277, 26279, 26280, 26281, 26314, 26331, 26335, 26340, 26343, 26348, 26355, 26356, 26358, 26359, 26375, 26399, 26401],
    name: "Ironman",
    rules: {
      members_only: true,
      points_for_place: 1
    }
  },
  ojcs: {
    categories: [
      { name: "Elite Junior Men" },
      { name: "Elite Junior Women" },
      { name: "Junior Men 10-12", reject: true },
      { name: "Junior Men 13-14 3/4/5" },
      { name: "Junior Men 13-14", reject: true },
      { name: "Junior Men 15-16 3/4/5" },
      { name: "Junior Men 15-16", reject: true },
      { name: "Junior Men 17-18 3/4/5" },
      { name: "Junior Men 17-18", reject: true },
      { name: "Junior Men 9-12 3/4/5" },
      { name: "Junior Men 9", reject: true },
      { name: "Junior Women 10-12", reject: true },
      { name: "Junior Women 13-14 3/4/5" },
      { name: "Junior Women 13-14", reject: true },
      { name: "Junior Women 15-16 3/4/5" },
      { name: "Junior Women 15-16", reject: true },
      { name: "Junior Women 17-18 3/4/5" },
      { name: "Junior Women 17-18", reject: true },
      { name: "Junior Women 9-12 3/4/5" },
      { name: "Junior Women 9", reject: true }
    ],
    competition_id: 25_816,
    events: [
      { id: 26_065, multiplier: 1 },
      { id: 26_280, multiplier: 1 },
      { id: 26_281, multiplier: 1 },
      { id: 25_900, multiplier: 1 },
      { id: 26_085, multiplier: 1 },
      { id: 26_067, multiplier: 1 }
    ],
    name: "Oregon Junior Cyclocross Series",
    rules: {
      maximum_events: -2,
      points_for_place: [30, 28, 26, 24, 22, 20, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      specific_events: true
    }
  },
  oregon_cup: {
    categories: [
      { name: "Senior Men" }
    ],
    competition_id: 25_815,
    events: [
      { id: 25_917, multiplier: 1 },
      { id: 25_920, multiplier: 1 },
      { id: 25_930, multiplier: 1 },
      { id: 25_939, multiplier: 1 },
      { id: 25_943, multiplier: 1 },
      { id: 26_053, multiplier: 1 }
    ],
    name: "Oregon Cup",
    rules: {
      members_only: true,
      points_for_place: [100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10],
      specific_events: true
    }
  },
  oregon_tt_cup: {
    categories: [
      { name: "Category 3 Men" },
      { name: "Category 3 Women" },
      { name: "Category 4/5 Men" },
      { name: "Category 4/5 Women" },
      { name: "Eddy Senior Men" },
      { name: "Eddy Senior Women" },
      { name: "Junior Men 10-12" },
      { name: "Junior Men 13-14" },
      { name: "Junior Men 15-16" },
      { name: "Junior Men 17-18" },
      { name: "Junior Women 10-14" },
      { name: "Junior Women 15-18" },
      { name: "Masters Men 30-39" },
      { name: "Masters Men 40-49" },
      { name: "Masters Men 50-59" },
      { name: "Masters Men 60-69" },
      { name: "Masters Men 70+" },
      { name: "Masters Women 30-39" },
      { name: "Masters Women 40-49" },
      { name: "Masters Women 50-59" },
      { name: "Masters Women 60-69" },
      { name: "Masters Women 70+" },
      { name: "Senior Men Pro/1/2" },
      { name: "Senior Women Pro/1/2" },
      { name: "Tandem" }
    ],
    competition_id: 25_820,
    events: [
      { id: 25_813, multiplier: 1 },
      { id: 25_869, multiplier: 1 },
      { id: 25_931, multiplier: 1 },
      { id: 25_936, multiplier: 1 },
      { id: 25_945, multiplier: 1 },
      { id: 25_966, multiplier: 1 },
      { id: 26_384, multiplier: 1 }
    ],
    name: "Oregon Time Trial Cup",
    rules: {
      members_only: true,
      place_by: "time",
      points_for_place: [20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      specific_events: true
    }
  },
  owps: {
    categories: [
      { name: "Women 1/2" },
      { name: "Women 3" },
      { name: "Women 4" }
    ],
    competition_id: 25_815,
    events: [
      { id: 25_917, multiplier: 1 },
      { id: 25_920, multiplier: 1 },
      { id: 25_930, multiplier: 1 },
      { id: 25_939, multiplier: 1 },
      { id: 25_943, multiplier: 1 },
      { id: 26_053, multiplier: 1 }
    ],
    name: "Oregon Womens Prestige Series",
    rules: {
      members_only: true,
      points_for_place: [25, 21, 18, 16, 14, 12, 10, 8, 7, 6, 5, 4, 3, 2, 1],
      specific_events: true
    }
  },
  pdx_stxc: {
    categories: [
      { name: "Category 1 Men U45" },
      { name: "Category 1 Men 45+" },
      { name: "Category 2 Men 40-49" },
      { name: "Category 2 Men 50-59" },
      { name: "Category 2 Men 60+" },
      { name: "Category 2 Men U40" },
      { name: "Category 2 Women 45+" },
      { name: "Category 2 Women U45" },
      { name: "Category 3 Men 10-13" },
      { name: "Category 3 Men 14-18" },
      { name: "Category 3 Men 19-39" },
      { name: "Category 3 Men 40-49" },
      { name: "Category 3 Men 50+" },
      { name: "Category 3 Women 10-13" },
      { name: "Category 3 Women 14-18" },
      { name: "Category 3 Women 19+" },
      { name: "Clydesdale" },
      { name: "Elite Men" },
      { name: "Elite/Category 1 Women" },
      { name: "Singlespeed" }
    ],
    competition_id: 26_304,
    event_id: 26_056,
    name: "Portland Short Track Series",
    rules: {
      maximum_events: -1,
      points_for_place: [
        100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14,
        13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
      ]
    }
  },
  pdx_stxc_june: {
    categories: [
      { name: "Category 1 Men U45" },
      { name: "Category 1 Men 45+" },
      { name: "Category 2 Men 40-49" },
      { name: "Category 2 Men 50-59" },
      { name: "Category 2 Men 60+" },
      { name: "Category 2 Men U40" },
      { name: "Category 2 Women 45+" },
      { name: "Category 2 Women U45" },
      { name: "Category 3 Men 10-13" },
      { name: "Category 3 Men 14-18" },
      { name: "Category 3 Men 19-39" },
      { name: "Category 3 Men 40-49" },
      { name: "Category 3 Men 50+" },
      { name: "Category 3 Women 10-13" },
      { name: "Category 3 Women 14-18" },
      { name: "Category 3 Women 19+" },
      { name: "Clydesdale" },
      { name: "Elite Men" },
      { name: "Elite/Category 1 Women" },
      { name: "Singlespeed" }
    ],
    competition_id: 26_305,
    expected: [26_054, 26_055, 26_057, 26_058],
    name: "Portland Short Track Series: June",
    rules: {
      maximum_events: -1,
      points_for_place: [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      specific_events: true
    },
    events: [
      { id: 26_054, multiplier: 1 },
      { id: 26_055, multiplier: 1 },
      { id: 26_057, multiplier: 1 },
      { id: 26_058, multiplier: 1 }
    ]
  },
  pdx_stxc_july: {
    categories: [
      { name: "Category 1 Men U45" },
      { name: "Category 1 Men 45+" },
      { name: "Category 2 Men 40-49" },
      { name: "Category 2 Men 50-59" },
      { name: "Category 2 Men 60+" },
      { name: "Category 2 Men U40" },
      { name: "Category 2 Women 45+" },
      { name: "Category 2 Women U45" },
      { name: "Category 3 Men 10-13" },
      { name: "Category 3 Men 14-18" },
      { name: "Category 3 Men 19-39" },
      { name: "Category 3 Men 40-49" },
      { name: "Category 3 Men 50+" },
      { name: "Category 3 Women 10-13" },
      { name: "Category 3 Women 14-18" },
      { name: "Category 3 Women 19+" },
      { name: "Clydesdale" },
      { name: "Elite Men" },
      { name: "Elite/Category 1 Women" },
      { name: "Singlespeed" }
    ],
    competition_id: 26_306,
    expected: [26_059, 26_060, 26_061, 26_062],
    name: "Portland Short Track Series: July",
    rules: {
      maximum_events: -1,
      points_for_place: [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      specific_events: true
    },
    events: [
      { id: 26_059, multiplier: 1 },
      { id: 26_060, multiplier: 1 },
      { id: 26_061, multiplier: 1 },
      { id: 26_062, multiplier: 1 }
    ]
  },
  tabor: {
    categories: [
      { name: "Senior Men" },
      { name: "Category 3 Men" },
      { name: "Category 4 Men" },
      { name: "Category 4/5 Women" },
      { name: "Category 5 Men" },
      { name: "Masters Men 50+" },
      { name: "Masters Men 40+" },
      { name: "Senior Women" }
    ],
    competition_id: 26_299,
    event_id: 26_072,
    name: "Mt. Tabor Series",
    rules: {
      double_points_for_last_event: true,
      points_for_place: [100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11]
    }
  },
  portland_trophy_cup: {
    categories: [
      { name: "Junior Open" },
      { name: "Junior Women" },
      { name: "Open 1/2" },
      { name: "Open 3/4 35+" },
      { name: "Open 3/4" },
      { name: "Open 50+" },
      { name: "Open 60+" },
      { name: "Open Beginner" },
      { name: "Open Masters 1/2 35+" },
      { name: "Open Singlespeed" },
      { name: "Women 1/2" },
      { name: "Women 3/4" },
      { name: "Women Beginner" },
      { name: "Women Singlespeed" }
    ],
    event_id: 26_072,
    name: "Portland Trophy Cup",
    rules: {
      double_points_for_last_event: true,
      points_for_place: [25, 20, 16, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 1]
    }
  },
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
      { name: "Masters Men 35-39" },
      { name: "Masters Men 40-44" },
      { name: "Masters Men 45-49" },
      { name: "Masters Men 50-54" },
      { name: "Masters Men 55-59" },
      { name: "Masters Men 60-64" },
      { name: "Masters Men 65-69" },
      { name: "Masters Men 70+" },
      { name: "Masters Women 40-44" },
      { name: "Masters Women 45-49" },
      { name: "Masters Women 50-54" },
      { name: "Masters Women 55-59" },
      { name: "Masters Women 60+" }
    ],
    competition_id: 25_831,
    name: "Age-Graded BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Overall",
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
      { name: "Senior Men" },
      { name: "Senior Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    competition_id: 25_823,
    events: [
      { id: 25_943, multiplier: 2 },
      { id: 26_335, multiplier: 0 }
    ],
    expect: [25_880, 26_027],
    do_no_expect: [26_034, 26_316, 26_416, 26_335],
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
      { name: "Category 1/2 Men" },
      { name: "Category 1/2 Women" },
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
    competition_id: 25_822,
    events: [
      { id: 25_903, multiplier: 2 },
      { id: 26_571, multiplier: 0 },
      { id: 26_593, multiplier: 0 }
    ],
    expect: [26_357],
    do_no_expect: [26_355, 26_356, 26_412, 26_571, 26_593, 26_571, 26_593, 26_418, 26_419],
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
    competition_id: 25_822,
    events: [
      { id: 25_946, multiplier: 2 },
      { id: 26_405, multiplier: 2 },
      { id: 26_442, multiplier: 2 }
    ],
    do_no_expect: [
      25_898, 25_900, 25_902, 25_903, 25_904, 25_953, 26_042, 26_045, 26_046, 26_047, 26_048, 26_065, 26_066, 26_068, 26_085, 26_089, 26_093,
      26_094, 26_095, 26_096, 26_097, 26_098, 26_099, 26_102, 26_116, 26_276, 26_277, 26_279, 26_280, 26_281, 26_355, 26_356, 26_357, 26_375,
      26_399, 26_418, 26_419, 26_571, 26_593
    ],
    expect: [
      25_875,
      25_876,
      25_884,
      25_885,
      25_934,
      25_944,
      25_946,
      26_064,
      26_140,
      26_141,
      26_142,
      26_143,
      26_147,
      26_212,
      26_250,
      26_251,
      26_252,
      26_401,
      26_405,
      26_442
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
      { name: "Senior Men" },
      { name: "Senior Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    competition_id: 25_825,
    do_no_expect: [25_922, 26_443, 26_299, 26_340],
    expect: [25_922],
    events: [
      { id: 25_939, multiplier: 2 },
      { id: 25_951, multiplier: 2 },
      { id: 26_069, multiplier: 1 },
      { id: 26_075, multiplier: 1 },
      { id: 26_272, multiplier: 1 },
      { id: 26_290, multiplier: 1 },
      { id: 26_294, multiplier: 1 },
      { id: 26_295, multiplier: 1 },
      { id: 26_299, multiplier: 1 },
      { id: 26_299, multiplier: 1 },
      { id: 26_337, multiplier: 1 },
      { id: 26_348, multiplier: 1 },
      { id: 26_388, multiplier: 1 },
      { id: 26_443, multiplier: 2 }
    ],
    name: "Road BAR",
    rules: {
      association_sanctioned_only: true,
      disciplines: %w[Circuit Gravel Road],
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
    competition_id: 25_828,
    events: [
      { id: 26_183, multiplier: 1 }
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
      { name: "Senior Men" },
      { name: "Senior Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    competition_id: 25_826,
    do_no_expect: [26_377, 26_384],
    events: [
      { id: 25_931, multiplier: 2 },
      { id: 25_936, multiplier: 2 },
      { id: 25_945, multiplier: 2 }
    ],
    expect: [25_985, 26_340],
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
      { name: "Senior Men" },
      { name: "Senior Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    competition_id: 25_827,
    do_no_expect: [26_176, 26_178, 26_179, 26_188, 26_189],
    events: [
      { id: 26_011, multiplier: 1 },
      { id: 26_014, multiplier: 1 },
      { id: 26_122, multiplier: 1 },
      { id: 26_149, multiplier: 2 },
      { id: 26_150, multiplier: 2 },
      { id: 26_151, multiplier: 2 },
      { id: 26_152, multiplier: 2 },
      { id: 26_154, multiplier: 2 },
      { id: 26_314, multiplier: 1 },
      { id: 26_347, multiplier: 1 },
      { id: 26_432, multiplier: 1 },
      { id: 26_433, multiplier: 1 },
      { id: 26_616, multiplier: 1 },
      { id: 26_617, multiplier: 1 },
      { id: 26_618, multiplier: 1 },
      { id: 26_619, multiplier: 1 }
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
      { name: "Senior Men" },
      { name: "Senior Women" },
      { name: "Singlespeed/Fixed" },
      { name: "Tandem" }
    ],
    competition_id: 25_821,
    name: "Overall BAR",
    rules: {
      association_sanctioned_only: true,
      discipline: "Overall",
      maximum_events: -4,
      members_only: true,
      points_for_place: (1..300).to_a.reverse,
      source_event_keys: %w[criterium_bar cyclocross_bar gravel_bar mountain_bike_bar road_bar short_track_bar time_trial_bar track_bar],
      weekday_events: true
    }
  },
  team_bar: {
    competition_id: 25_830,
    name: "Team BAR",
    rules: {
      association_sanctioned_only: true,
      members_only: true,
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      team: true,
      weekday_events: false
    }
  }
}.freeze
