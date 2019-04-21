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
    rules: {
      maximum_events: -1,
      points_for_place: [15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
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
    rules: {
      disciplines: ["Criterium"],
      members_only: true,
      name: "Criterium BAR",
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
    do_no_expect: [26_355, 26_356, 26_412],
    rules: {
      disciplines: ["Cyclocross"],
      members_only: true,
      name: "Cyclocross BAR",
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
    rules: {
      disciplines: ["Mountain Bike", "Downhill", "Super D"],
      members_only: true,
      name: "Mountain Bike BAR",
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false
    }
  },
  gravel_bar: {
    categories: [
      { name: "Junior Men" },
      { name: "Junior Women" },
      { name: "Masters Men" },
      { name: "Masters Women" },
      { name: "Open Men" },
      { name: "Open Women" }
    ],
    competition_id: 25_829,
    rules: {
      disciplines: ["Gravel", "Gran Fondo"],
      members_only: true,
      name: "Gravel BAR",
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
    events: [
      { id: 25_939, multiplier: 2 },
      { id: 25_951, multiplier: 2 },
      { id: 26_443, multiplier: 2 }
    ],
    rules: {
      disciplines: ["Circuit Race", "Road"],
      members_only: true,
      name: "Road BAR",
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
    rules: {
      disciplines: ["Short Track"],
      members_only: true,
      name: "Short Track BAR",
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
    events: [
      { id: 25_931, multiplier: 2 },
      { id: 25_936, multiplier: 2 },
      { id: 25_945, multiplier: 2 }
    ],
    rules: {
      disciplines: ["Time Trial"],
      members_only: true,
      name: "Time Trial BAR",
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
    events: [
      { id: 26_149, multiplier: 2 },
      { id: 26_150, multiplier: 2 },
      { id: 26_151, multiplier: 2 },
      { id: 26_152, multiplier: 2 },
      { id: 26_154, multiplier: 2 },
      { id: 26_314, multiplier: 2 }
    ],
    rules: {
      disciplines: ["Track"],
      members_only: true,
      name: "Track BAR",
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
    rules: {
      maximum_events: -4,
      members_only: true,
      name: "Overall BAR",
      points_for_place: (1..300).to_a.reverse,
      source_event_keys: %w[criterium_bar cyclocross_bar gravel_bar mountain_bike_bar road_bar short_track_bar time_trial_bar track_bar],
      weekday_events: true
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
    rules: {
      maximum_events: -1,
      minimum_events: 3,
      points_for_place: [26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
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
    rules: {
      maximum_events: -1,
      minimum_events: 4,
      name: "Gran Prix Carl Decker",
      points_for_place: [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
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
    rules: {
      members_only: true,
      name: "Oregon Cup",
      points_for_place: [100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10],
      specific_events: true
    }
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
    rules: {
      double_points_for_last_event: true,
      points_for_place: [100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11]
    }
  }
}.freeze
