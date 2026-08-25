// الأزرار المخصصة — مطابقة لـ btn.primary / ghost / danger في الموقع
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

enum BtnStyle { primary, ghost, danger, dangerText }

class AppButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final BtnStyle style;
  final VoidCallback? onPressed;
  final bool small;
  final bool iconOnly;
  final bool expanded;

  const AppButton({
    super.key,
    this.label,
    this.icon,
    this.style = BtnStyle.primary,
    this.onPressed,
    this.small = false,
    this.iconOnly = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = style == BtnStyle.primary;
    final isGhost = style == BtnStyle.ghost;
    final isDanger = style == BtnStyle.danger;
    final isDangerText = style == BtnStyle.dangerText;

    final bgColor = isPrimary
        ? AppColors.grass
        : isDanger
            ? const Color(0x12E5543F)
            : Colors.transparent;

    final fgColor = isPrimary
        ? const Color(0xFF07130A)
        : isDangerText
            ? AppColors.redSoft
            : isDanger
                ? AppColors.redSoft
                : AppColors.ink;

    final borderColor = isGhost
        ? AppColors.lineStrong
        : isDanger
            ? const Color(0x73E5543F)
            : Colors.transparent;

    final padV = small ? 7.0 : 11.0;
    final padH = iconOnly ? 9.0 : (small ? 13.0 : 18.0);
    final fontSize = small ? 13.0 : 15.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: small ? 16 : 18, color: fgColor),
                if (label != null && !iconOnly) const SizedBox(width: 8),
              ],
              if (label != null && !iconOnly)
                Flexible(
                  child: Text(
                    label!,
                    style: AppTheme.heading(
                      size: fontSize,
                      weight: FontWeight.w600,
                      color: fgColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
