import 'package:flutter/material.dart';

import '../models/lead.dart';
import '../theme.dart';

class SavedLeadCard extends StatelessWidget {
  const SavedLeadCard({super.key, required this.lead});

  final NewLead lead;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCDE7BA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1452A51F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.brightGreen, size: 26),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lead saved',
                  style: TextStyle(
                    color: AppColors.greenText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Just now',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  lead.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (lead.companyName != null)
                      Text(
                        lead.companyName!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.body,
                          fontSize: 16,
                        ),
                      ),
                    Text(
                      lead.emailAddress,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.body,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
