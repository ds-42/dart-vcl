part of vcl;


class Date
{
  final int year;
  final int month;
  final int day;

  Date._(this.year, this.month, this.day);

  factory Date(int year, [int month=1, int day=1])
  {
    // norm month
    while(month<1)
    {
      month+=12;
      year--;
    }

    while(month>12)
    {
      month-=12;
      year++;
    }


    var days = SysDate.monthDaysOfYear(year);

    // norm days by month
    while(day<=0)
    {
      if(--month<1)
      {
        month+=12;
        days = SysDate.monthDaysOfYear(--year);
      }
      day+=days[month-1];
    }

    int md = days[month-1];
    while(day>md)
    {
      if(++month>12)
      {
        month-=12;
        days = SysDate.monthDaysOfYear(++year);
      }
      day-=md;
      md = days[month-1];
    }

    return Date._(year, month, day);
  }



  factory Date.now()
  {
    var date = DateTime.now();
    return Date._(date.year, date.month, date.day);
  }

  factory Date.days(int date)
  {
    if(date == 0)
      return Date(0, 0, 0);

    const d1 = 365;
    const d4 = d1 * 4 + 1;
    const d100 = d4 * 25 - 1;
    const d400 = d100 * 4 + 1;

    int d = date;
    d--;
    int y = 1;
    while(d >= d400)
    {
      d-=d400;
      y+=400;
    }

    int i;
    i = d ~/ d100;
    d = d % d100;
    if(i == 4)
    {
      i--;
      d+=d100;
    }
    y+=i * 100;

    i = d ~/ d4;
    d = d % d4;
    y+=i * 4;

    i = d ~/ d1;
    d = d % d1;
    if(i == 4)
    {
      i--;
      d+=d1;
    }
    y+=i;

    var days = SysDate.monthDaysOfYear(y);

    int m=0;
    for(; m<11; m++)
    {
      if(d<days[m])
        break;
      d-=days[m];
    }
    return Date._(y, m+1, d+1);
  }


}

