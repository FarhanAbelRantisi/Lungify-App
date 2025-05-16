import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:healthbot_app/utils/text_styles.dart';
import 'package:healthbot_app/viewmodel/reminder_viewmodel.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {

  void _showEditReminderDialog(BuildContext context, ReminderViewModel reminderVM, Map<String, dynamic> reminder) {
    final titleController = TextEditingController(text: reminder['title']);
    final notesController = TextEditingController(text: reminder['notes']);
    String selectedCategory = reminder['category'] ?? 'drug';
    
    DateTime? selectedDate;
    if (reminder['date'] != null) {
      selectedDate = DateFormat('yyyy-MM-dd').parse(reminder['date']);
    }
    
    TimeOfDay? selectedTime;
    if (reminder['time'] != null) {
      final timeParts = reminder['time'].split(':');
      selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: const [
                      DropdownMenuItem(value: 'drug', child: Text('Medicine')),
                      DropdownMenuItem(value: 'eat', child: Text('Eat')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : '',
                    ),
                    onTap: () async {
                      DateTime now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? now,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 2),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF24786D),
                                onPrimary: Color(0xFFF9F9F9),
                                onSurface: Color(0xFF24786D),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Time',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      suffixIcon: const Icon(Icons.access_time, color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                    controller: TextEditingController(
                      text: selectedTime != null
                          ? selectedTime!.format(context)
                          : '',
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF24786D),
                                onPrimary: Colors.white,
                                onSurface: Color(0xFF24786D),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      // Tombol Delete
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(context, reminderVM, reminder['id']);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFFE80202),
                            side: const BorderSide(color: Color(0xFFE80202)),
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Delete", style: AppTextStyles.interMedium16),
                        ),
                      ),

                      const SizedBox(width: 12), // Jarak antar tombol

                      // Tombol Save
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty ||
                                selectedDate == null ||
                                selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill all required fields')),
                              );
                              return;
                            }

                            final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
                            final now = DateTime.now();
                            final time = DateTime(now.year, now.month, now.day,
                                selectedTime!.hour, selectedTime!.minute);
                            final formattedTime = DateFormat.Hm().format(time);

                            final updatedReminder = {
                              'title': titleController.text,
                              'category': selectedCategory,
                              'date': formattedDate,
                              'time': formattedTime,
                              'notes': notesController.text,
                            };

                            reminderVM.updateReminder(reminder['id'], updatedReminder);
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF24786D),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Save", style: AppTextStyles.interMedium16,),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 21),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ReminderViewModel reminderVM, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              reminderVM.deleteReminder(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _getFilteredReminders(ReminderViewModel vm) {
    int selectedDay = int.parse(vm.days[vm.selectedIndex]['date']!);
    int selectedMonth = vm.selectedMonthIndex + 1;
    DateTime now = DateTime.now();
    String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, selectedMonth, selectedDay));

    return vm.reminders.where((reminder) => reminder['date'] == selectedDate).toList();
  }

  
  @override
    void initState() {
      super.initState();
      final vm = Provider.of<ReminderViewModel>(context, listen: false);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          vm.selectedIndex * 62.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }

  String _getImageByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'drug':
        return 'assets/images/icon_drug.svg';
      case 'eat':
        return 'assets/images/icon_eat.svg';
      default:
        return 'assets/images/icon_other.svg';
    }
  }

  String _getClosestTime(List<Map<String, dynamic>> reminders) {
    final now = DateTime.now();

    final parsedTimes = reminders.map((e) {
      final timeString = e['time'] as String?;
      if (timeString == null) return now.add(Duration(days: 365)); // fallback jauh ke depan
      final time = DateFormat("HH:mm").parse(timeString);
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }).toList();

    parsedTimes.sort((a, b) => a.compareTo(b));

    for (var time in parsedTimes) {
      if (time.isAfter(now)) {
        return DateFormat("HH:mm").format(time);
      }
    }

    return '';
  }

  TimeOfDay _parseTime(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return const TimeOfDay(hour: 0, minute: 0);
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    final reminderVM = Provider.of<ReminderViewModel>(context);
    final String closestTime = _getClosestTime(reminderVM.filteredReminders);
    final filteredReminders = _getFilteredReminders(reminderVM);
    final sortedReminders = List<Map<String, dynamic>>.from(filteredReminders)
    ..sort((a, b) {
      final timeA = _parseTime(a['time']);
      final timeB = _parseTime(b['time']);
      return timeA.compareTo(timeB);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        elevation: 0,
        title: Text('Reminder', style: AppTextStyles.interBold20,)
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF24786D),
        onPressed: () => _showAddReminderDialog(context, reminderVM),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showMonthPicker(context, reminderVM),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF797C7B), width: 1),
                      ),
                      child: Row(
                        children: [
                          Text(reminderVM.months[reminderVM.selectedMonthIndex],
                              style: AppTextStyles.interBold14),
                          const SizedBox(width: 6),
                          SvgPicture.asset('assets/images/icon_dropdown.svg')
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    'assets/images/icon_calender2.svg',
                    width: 28,
                    height: 28,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// Horizontal date selector
              SizedBox(
                height: 55,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: reminderVM.days.length,
                  itemBuilder: (context, index) {
                    final isSelected = reminderVM.selectedIndex == index;
                    final day = reminderVM.days[index]['day']!;
                    final date = reminderVM.days[index]['date']!;
                    return GestureDetector(
                      onTap: () {
                        reminderVM.selectIndex(index);
                        _scrollController.animateTo(
                          index * 62.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD7F1FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF5BC8FF) : const Color(0xFFCACACA),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(day,
                                style: AppTextStyles.interMedium12.copyWith(
                                    color: isSelected
                                        ? const Color(0xFF1E1E1E)
                                        : const Color(0xFF797C7B))),
                            Text(date,
                                style: AppTextStyles.interMedium16.copyWith(
                                    color: isSelected
                                        ? const Color(0xFF1E1E1E)
                                        : const Color(0xFF797C7B))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              /// Reminder list
              ...sortedReminders.map((reminder) {
                final isClosest = reminder['time'] == closestTime;
                final isLast = reminder == sortedReminders.last;
                final borderColor = isClosest ? const Color(0xFF5BC8FF) : const Color(0xFFCACACA);
                final bgColor = isClosest ? const Color(0xFFD7F1FF) : Colors.transparent;

                return GestureDetector(
                  onTap: () => _showEditReminderDialog(context, reminderVM, reminder),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            reminder['time']!,
                            style: AppTextStyles.interRegular14.copyWith(color: const Color(0xFF1E1E1E)),
                          ),
                        ),
                        
                        const SizedBox(width: 12),

                        Column(
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD9D9D9),
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 1,
                                height: 75,
                                color: const Color(0xFFD9D9D9),
                              ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  _getImageByCategory(reminder['category'] ?? 'other'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reminder['title'] ?? '-',
                                        style: AppTextStyles.interMedium14
                                            .copyWith(color: const Color(0xFF1E1E1E)),
                                      ),
                                      Text(
                                        reminder['notes'] ?? '-',
                                        style: AppTextStyles.interRegular12
                                            .copyWith(color: const Color(0xFF797C7B)),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context, ReminderViewModel reminderVM) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = 'drug';
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g., Paracetamol, Lunch',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: const [
                      DropdownMenuItem(value: 'drug', child: Text('Medicine', style: AppTextStyles.interMedium14,)),
                      DropdownMenuItem(value: 'eat', child: Text('Eat', style: AppTextStyles.interMedium14)),
                      DropdownMenuItem(value: 'other', child: Text('Other', style: AppTextStyles.interMedium14)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : '',
                    ),
                    onTap: () async {
                      DateTime now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 2),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF24786D),
                                onPrimary: Color(0xFFF9F9F9),
                                onSurface: Color(0xFF1E1E1E),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Time',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      suffixIcon: const Icon(Icons.access_time, color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                    controller: TextEditingController(
                      text: selectedTime != null
                          ? selectedTime!.format(context)
                          : '',
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF24786D),
                                onPrimary: Color(0xFFF9F9F9),
                                onSurface: Color(0xFF1E1E1E),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      hintText: 'e.g., 1 tablet, 500 kCal',
                      labelStyle: const TextStyle(color: Color(0xFF24786D)),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF24786D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24786D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty || selectedDate == null || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all required fields')),
                        );
                        return;
                      }

                      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
                      final now = DateTime.now();
                      final time = DateTime(now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute);
                      final formattedTime = DateFormat.Hm().format(time);

                      final newReminder = {
                        'title': titleController.text,
                        'category': selectedCategory,
                        'date': formattedDate,
                        'time': formattedTime,
                        'notes': notesController.text,
                      };

                      reminderVM.addReminder(newReminder);
                      Navigator.pop(context);
                    },
                    child: const Text("Add Reminder", style: AppTextStyles.interMedium16),
                  ),
                  const SizedBox(height: 21),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMonthPicker(BuildContext context, ReminderViewModel reminderVM) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: reminderVM.months.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reminderVM.months[index]),
            onTap: () {
              reminderVM.setMonth(index);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}