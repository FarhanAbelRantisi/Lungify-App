import 'package:flutter/material.dart';
import 'package:healthbot_app/utils/text_styles.dart';

class ReminderCard extends StatelessWidget {
  final List<Map<String, dynamic>> reminders;
  final String hari;
  final String tanggal;
  final Color? highlightColor;
  final Color? highlightBorderColor;

  const ReminderCard({
    super.key,
    required this.reminders,
    required this.hari,
    required this.tanggal,
    this.highlightColor,
    this.highlightBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E9F3)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hari, style: AppTextStyles.interMedium14),
                Text(tanggal, style: AppTextStyles.interBold20),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: reminders.isEmpty
              ? Center(
                  child: Text(
                    'No reminders for today',
                    style: AppTextStyles.interMedium16.copyWith(color: const Color(0xFF797C7B)),
                  ),
                )
              : ListView.builder(
                  itemCount: reminders.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    final bool isFirst = index == 0;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8, top: index == 0 ? 0 : 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isFirst ? highlightColor ?? const Color(0xFFFDFDFF) : const Color(0xFFFDFDFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isFirst ? highlightBorderColor ?? const Color(0xFFE3E9F3) : const Color(0xFFE3E9F3),
                          ),
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF14C38E),
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    reminder['title'] ?? 'No title',
                                    style: AppTextStyles.interMedium16,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const Spacer(),

                                  Text(
                                    reminder['time'] ?? '',
                                    style: AppTextStyles.interMedium14
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}