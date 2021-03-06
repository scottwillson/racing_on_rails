# frozen_string_literal: true

# Stolen from CountryCodeSelect at http://github.com/russ/country_code_select
module Countries
  COUNTRIES = [%w[Afghanistan AF], %w[Albania AL], %w[Algeria DZ], ["American Samoa", "AS"], %w[Andorra AD], %w[Angola AO],
               %w[Anguilla AI], %w[Antarctica AQ], ["Antigua and Barbuda", "AG"], %w[Argentina AR], %w[Armenia AM], %w[Aruba AW],
               %w[Australia AU], %w[Austria AT], %w[Azerbaidjan AZ], %w[Bahamas BS], %w[Bahrain BH], %w[Banglades BD], %w[Barbados BB],
               %w[Belarus BY], %w[Belgium BE], %w[Belize BZ], %w[Benin BJ], %w[Bermuda BM], %w[Bolivia BO], %w[Bosnia-Herzegovina BA],
               %w[Botswana BW], ["Bouvet Island", "BV"], %w[Brazil BR], ["British Indian O. Terr.", "IO"], ["Brunei Darussalam", "BN"], %w[Bulgaria BG],
               ["Burkina Faso", "BF"], %w[Burundi BI], %w[Buthan BT], %w[Cambodia KH], %w[Cameroon CM], %w[Canada CA], ["Cape Verde", "CV"],
               ["Cayman Islands", "KY"], ["Central African Rep.", "CF"], %w[Chad TD], %w[Chile CL], %w[China CN], ["Christmas Island", "CX"],
               ["Cocos (Keeling) Isl.", "CC"], %w[Colombia CO], %w[Comoros KM], %w[Congo CG], ["Cook Islands", "CK"], ["Costa Rica", "CR"],
               %w[Croatia HR], %w[Cuba CU], %w[Cyprus CY], ["Czech Republic", "CZ"], %w[Czechoslovakia CS], %w[Denmark DK], %w[Djibouti DJ],
               %w[Dominica DM], ["Dominican Republic", "DO"], ["East Timor", "TP"], %w[Ecuador EC], %w[Egypt EG], ["El Salvador", "SV"],
               ["Equatorial Guinea", "GQ"], %w[Estonia EE], %w[Ethiopia ET], ["Falkland Isl.(UK)", "FK"], ["Faroe Islands", "FO"], %w[Fiji FJ],
               %w[Finland FI], %w[France FR], ["France (European Ter.)", "FX"], ["French Southern Terr.", "TF"], %w[Gabon GA], %w[Gambia GM],
               %w[Georgia GE], %w[Germany DE], %w[Ghana GH], %w[Gibraltar GI], ["Great Britain (UK)", "GB"], %w[Greece GR], %w[Greenland GL],
               %w[Grenada GD], ["Guadeloupe (Fr.)", "GP"], ["Guam (US)", "GU"], %w[Guatemala GT], %w[Guinea GN], ["Guinea Bissau", "GW"],
               %w[Guyana GY], ["Guyana (Fr.)", "GF"], %w[Haiti HT], ["Heard & McDonald Isl.", "HM"], %w[Honduras HN], ["Hong Kong", "HK"],
               %w[Hungary HU], %w[Iceland IS], %w[India IN], %w[Indonesia ID], %w[Iran IR], %w[Iraq IQ], %w[Ireland IE], %w[Israel IL],
               %w[Italy IT], ["Ivory Coast", "CI"], %w[Jamaica JM], %w[Japan JP], %w[Jordan JO], %w[Kazachstan KZ], %w[Kenya KE],
               %w[Kirgistan KG], %w[Kiribati KI], ["Korea (North)", "KP"], ["Korea (South)", "KR"], %w[Kuwait KW], %w[Laos LA], %w[Latvia LV],
               %w[Lebanon LB], %w[Lesotho LS], %w[Liberia LR], %w[Libya LY], %w[Liechtenstein LI], %w[Lithuania LT], %w[Luxembourg LU],
               %w[Macau MO], %w[Madagascar MG], %w[Malawi MW], %w[Malaysia MY], %w[Maldives MV], %w[Mali ML], %w[Malta MT],
               ["Marshall Islands", "MH"], ["Martinique (Fr.)", "MQ"], %w[Mauritania MR], %w[Mauritius MU], %w[Mexico MX], %w[Micronesia FM],
               %w[Moldavia MD], %w[Monaco MC], %w[Mongolia MN], %w[Montserrat MS], %w[Morocco MA], %w[Mozambique MZ], %w[Myanmar MM],
               %w[Namibia NA], %w[Nauru NR], %w[Nepal NP], ["Netherland Antilles", "AN"], %w[Netherlands NL], ["Neutral Zone", "NT"],
               ["New Caledonia (Fr.)", "NC"], ["New Zealand", "NZ"], %w[Nicaragua NI], %w[Niger NE], %w[Nigeria NG], %w[Niue NU],
               ["Norfolk Island", "NF"], ["Northern Mariana Isl.", "MP"], %w[Norway NO], %w[Oman OM], %w[Pakistan PK], %w[Palau PW],
               %w[Panama PA], ["Papua New", "PG"], %w[Paraguay PY], %w[Peru PE], %w[Philippines PH], %w[Pitcairn PN], %w[Poland PL],
               ["Polynesia (Fr.)", "PF"], %w[Portugal PT], ["Puerto Rico (US)", "PR"], %w[Qatar QA], ["Reunion (Fr.)", "RE"], %w[Romania RO],
               ["Russian Federation", "RU"], %w[Rwanda RW], ["Saint Lucia", "LC"], %w[Samoa WS], ["San Marino", "SM"], ["Saudi Arabia", "SA"],
               %w[Senegal SN], %w[Seychelles SC], ["Sierra Leone", "SL"], %w[Singapore SG], ["Slovak Republic", "SK"], %w[Slovenia SI],
               ["Solomon Islands", "SB"], %w[Somalia SO], ["South Africa", "ZA"], ["Soviet Union", "SU"], %w[Spain ES], ["Sri Lanka", "LK"],
               ["St. Helena", "SH"], ["St. Pierre & Miquelon", "PM"], ["St. Tome and Principe", "ST"], ["St.Kitts Nevis Anguilla", "KN"],
               ["St.Vincent & Grenadines", "VC"], %w[Sudan SD], %w[Suriname SR], ["Svalbard & Jan Mayen Is", "SJ"], %w[Swaziland SZ], %w[Sweden SE],
               %w[Switzerland CH], %w[Syria SY], %w[Tadjikistan TJ], %w[Taiwan TW], %w[Tanzania TZ], %w[Thailand TH], %w[Togo TG],
               %w[Tokelau TK], %w[Tonga TO], ["Trinidad & Tobago", "TT"], %w[Tunisia TN], %w[Turkey TR], %w[Turkmenistan TM],
               ["Turks & Caicos Islands", "TC"], %w[Tuvalu TV], %w[Uganda UG], %w[Ukraine UA], ["United Arab Emirates", "AE"], ["United Kingdom", "UK"],
               ["United States", "US"], %w[Uruguay UY], ["US Minor outlying Isl.", "UM"], %w[Uzbekistan UZ], %w[Vanuatu VU], ["Vatican City State", "VA"],
               %w[Venezuela VE], %w[Vietnam VN], ["Virgin Islands (British)", "VG"], ["Virgin Islands (US)", "VI"], ["Wallis & Futuna Islands", "WF"],
               ["Western Sahara", "EH"], %w[Yemen YE], %w[Yugoslavia YU], %w[Zaire ZR], %w[Zambia ZM], %w[Zimbabwe ZW]].freeze
end
