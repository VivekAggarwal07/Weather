const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String weekdayName(DateTime d) => _weekdays[d.weekday - 1];
String shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String _two(int n) => n.toString().padLeft(2, '0');

/// e.g. "Nov 3, 14:05"
String timestamp(DateTime d) => '${shortDate(d)}, ${_two(d.hour)}:${_two(d.minute)}';
