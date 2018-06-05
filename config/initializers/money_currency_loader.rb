curr = {
  priority:               1,
  iso_code:               "UAH",
  name:                   "Ukrainian Hryvnia",
  symbol:                 "грн.",
  alternate_symbols:      [],
  subunit:                "Kopiyka",
  subunit_to_unit:        100,
  symbol_first:           false,
  html_entity:            "грн.",
  decimal_mark:           ".",
  thousands_separator:    ",",
  iso_numeric:            "980",
  smallest_denomination:  1
}

Money::Currency.register(curr)
