import 'package:flutter/material.dart';
import 'package:healthbot_app/utils/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConsultationCard extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const ConsultationCard({
    super.key,
    required this.onNavigateToTab,
  });

@override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFFDFDFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE3E9F3),
          width: 1,
        ),
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Let\'s consult your health!',
                style: AppTextStyles.interBold20
              ),

              const Spacer(),

              SvgPicture.asset('assets/images/icon_history.svg', width: 20),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Talk with our AI bot to get answers to your symptoms.',
            style: AppTextStyles.interRegular14,
            textAlign: TextAlign.start,
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onNavigateToTab(2), // Navigate to Healthbot_screen (index 2)
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24786D),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Consule', 
                style: AppTextStyles.interBold16.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}