import 'package:flutter/material.dart';

class ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? progress;
  final bool outlined;

  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.progress,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (progress != null)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                backgroundColor ?? theme.primaryColor,
              ),
            ),
          Material(
            color: outlined ? Colors.transparent : (backgroundColor ?? theme.primaryColor),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: icon != null ? 16 : 24,
                  vertical: 12,
                ),
                decoration: outlined
                    ? BoxDecoration(
                        border: Border.all(
                          color: backgroundColor ?? theme.primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Row(
                  mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            foregroundColor ?? 
                            (outlined 
                                ? (backgroundColor ?? theme.primaryColor)
                                : Colors.white),
                          ),
                        ),
                      )
                    else if (icon != null)
                      Icon(
                        icon,
                        color: foregroundColor ?? 
                               (outlined 
                                   ? (backgroundColor ?? theme.primaryColor)
                                   : Colors.white),
                      ),
                    if ((icon != null || isLoading) && label.isNotEmpty)
                      const SizedBox(width: 8),
                    if (label.isNotEmpty)
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: foregroundColor ?? 
                                 (outlined 
                                     ? (backgroundColor ?? theme.primaryColor)
                                     : Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 