import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
import '../validation.dart';
import 'socreate_logo.dart';

/// Logo plus "Signed in as {name}" with a menu holding Sign out.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.employeeName});

  final String employeeName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 10, 12, 12),
          child: Row(
            children: [
              const SoCreateLogo(width: 150),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _AccountMenu(employeeName: employeeName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({required this.employeeName});

  final String employeeName;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Account',
      position: PopupMenuPosition.under,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        PopupMenuItem<void>(
          enabled: false,
          child: Text(
            employeeName,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        PopupMenuItem<void>(
          onTap: () => AppServices.of(context).signOut(context),
          child: const Row(
            children: [
              Icon(Icons.logout, size: 20, color: AppColors.navy),
              SizedBox(width: 12),
              Text('Sign out', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Signed in as',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    firstNameOf(employeeName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
