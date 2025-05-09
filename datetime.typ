#import "@preview/oxifmt:0.2.1": strfmt

#let parse_datetime_to_unix(timestamp) = {
  // Returns Unix timestamp in seconds
  let (date_part, time_part) = timestamp.split(" ");
  let (year, month, day) = date_part.split("-").map(int);
  let (hour, minute, second) = time_part.split(":").map(float);

  let is_leap(year) = calc.rem(year, 4) == 0 and (calc.rem(year, 100) != 0 or calc.rem(year, 400) == 0);

   // Calculate total days from 1970 to the given year
  let total_days = range(1970, year).map(y => if is_leap(y) {
      366
    } else {
      365
    }).sum() + range(1, month).map(m =>
      if m == 2 {
        if is_leap(year) { 29 } else { 28 }
      } else if m in (4, 6, 9, 11) {
        30
      } else { 31 }
    ).sum() + (day - 1)

  // Convert total days to seconds and add time components
  (((total_days * 24) + hour) * 60 + minute) * 60 + second
}
#let format_unix_to_time(unix) = {
  let is_leap(year) = calc.rem(year, 4) == 0 and (calc.rem(year, 100) != 0 or calc.rem(year, 400) == 0);

  let days_in_month(month, year) = if month == 2 {
    if is_leap(year) { 29 } else { 28 }
  } else if month in (4, 6, 9, 11) {
    30
  } else {
    31
  }

  let total_days = calc.floor(unix / 86400)
  let remaining_seconds = unix - total_days * 86400

  // Figure out the year
  let year = 1970
  let days = total_days
  while days >= if is_leap(year) { 366 } else { 365 } {
    days -= if is_leap(year) { 366 } else { 365 }
    year += 1
  }

  // Figure out the month
  let month = 1
  while days >= days_in_month(month, year) {
    days -= days_in_month(month, year)
    month += 1
  }

  let day = days + 1

  // Now for the time
  let hour = calc.floor(remaining_seconds / 3600);
  let minute = calc.floor(calc.rem(remaining_seconds, 3600) / 60);
  let second = calc.floor(calc.rem(remaining_seconds, 60));

  // Format as string
  //strfmt("{}-{:02}-{:02} {:02}:{:02}:{:02}", year, month, day, hour, minute, second)
  strfmt("{:02}:{:02}", hour, minute)
}
