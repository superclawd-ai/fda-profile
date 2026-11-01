---
name: dates-money-units
description: Use whenever an answer depends on time zones, scheduling across countries, business days, holidays, durations, currency conversion, prices with tax, or unit conversion.
---

# Dates, money and units

**Compute it in code, never in your head.** Show the inputs and formula for anything involving money.

## Time

```python
from datetime import datetime
from zoneinfo import ZoneInfo
t = datetime(2026, 11, 3, 15, 0, tzinfo=ZoneInfo("America/Sao_Paulo"))
t.astimezone(ZoneInfo("Europe/Lisbon"))
```

IANA names only (`America/New_York`, never "EST"). Business days and holidays: `holidays` package
(`holidays.country_holidays("BR", subdiv="SP")`) + `numpy.busday_count`. Meeting invites: `icalendar`
to make an `.ics` file. Write dates unambiguously: "Tue 3 Nov 2026, 15:00 São Paulo (18:00 Lisbon)".

## Money

Exchange rates from the European Central Bank (free, no key):
`curl -s "https://api.frankfurter.dev/v1/latest?base=USD&symbols=BRL,EUR"`. Always state the rate and its
date; use `decimal.Decimal` for amounts; round only at the end. Format for the reader's locale with
`babel.numbers.format_currency(1234.5, "BRL", locale="pt_BR")` → `R$ 1.234,50`.

## Units

`pint`: `ureg = pint.UnitRegistry(); (3 * ureg.mile).to("km")`.
