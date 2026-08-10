// import 'dart:ui' as ui;

// import 'package:architecture_test/core/global/dimensions.dart';
// import 'package:architecture_test/core/theme/app_texts/app_text_styles.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';

// import '../../theme/theme_manager/theme_extensions.dart';

// class CustomDivider extends StatelessWidget {
//   final Color? color;
//   final double thickness;
//   final double indent;
//   final double endIndent;
//   final bool showOrText;
//   final String? customText;
//   final bool isVertical;
//   final List<Color>? gradientColors;
//   final DividerStyle style;
//   final double dashSpacing;
//   final double dashWidth;
//   final TextStyle? textStyle;
//   final Color? textBackgroundColor;
//   final double textBorderRadius;
//   final EdgeInsets textPadding;
//   final bool addShadow;
//   final bool addGlow;
//   final Color? glowColor;
//   final double maxTextWidth;

//   const CustomDivider({
//     super.key,
//     this.color,
//     this.thickness = 1.0,
//     this.indent = 0.0,
//     this.endIndent = 0.0,
//     this.showOrText = false,
//     this.customText,
//     this.isVertical = false,
//     this.gradientColors,
//     this.style = DividerStyle.solid,
//     this.dashSpacing = 5.0,
//     this.dashWidth = 5.0,
//     this.textStyle,
//     this.textBackgroundColor,
//     this.textBorderRadius = 20.0,
//     this.textPadding = const EdgeInsets.symmetric(
//       horizontal: 16.0,
//       vertical: 8.0,
//     ),
//     this.addShadow = false,
//     this.addGlow = false,
//     this.glowColor,
//     this.maxTextWidth = 200.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (showOrText) {
//       return _buildDividerWithText(context);
//     }

//     return _buildSimpleDivider(context);
//   }

//   Widget _buildDividerWithText(BuildContext context) {
//     final resolvedColor = color ?? context.customAppColors.grey300;
//     final text = customText ?? 'or'.tr();
//     final defaultTextStyle = context.f14sb.copyWith(color: resolvedColor);

//     if (gradientColors != null && gradientColors!.length > 1) {
//       return LayoutBuilder(
//         builder: (context, constraints) {
//           return _buildDividerWithContinuousGradient(
//             text,
//             defaultTextStyle,
//             constraints,
//             resolvedColor,
//           );
//         },
//       );
//     }

//     if (isVertical) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Expanded(child: _buildSimpleDivider(context)),
//           _buildTextContainer(text, defaultTextStyle, resolvedColor),
//           Expanded(child: _buildSimpleDivider(context)),
//         ],
//       );
//     } else {
//       return SizedBox(
//         width: double.infinity,
//         child: Row(
//           children: [
//             Expanded(child: _buildSimpleDivider(context)),
//             _buildTextContainer(text, defaultTextStyle, resolvedColor),
//             Expanded(child: _buildSimpleDivider(context)),
//           ],
//         ),
//       );
//     }
//   }

//   Widget _buildDividerWithContinuousGradient(
//     String text,
//     TextStyle defaultTextStyle,
//     BoxConstraints constraints,
//     Color resolvedColor,
//   ) {
//     if (isVertical) {
//       return SizedBox(
//         width: thickness,
//         child: Column(
//           children: [
//             Expanded(
//               child: CustomPaint(
//                 painter: _ContinuousGradientDividerPainter(
//                   color: resolvedColor,
//                   thickness: thickness,
//                   style: style,
//                   dashSpacing: dashSpacing,
//                   dashWidth: dashWidth,
//                   gradientColors: gradientColors,
//                   isVertical: isVertical,
//                   addGlow: addGlow,
//                   glowColor: glowColor ?? resolvedColor,
//                   showText: true,
//                   totalHeight: constraints.maxHeight,
//                   totalWidth: constraints.maxWidth,
//                 ),
//                 child: Container(),
//               ),
//             ),
//             _buildTextContainerForGradient(
//               text,
//               defaultTextStyle,
//               resolvedColor,
//             ),
//             Expanded(child: Container()),
//           ],
//         ),
//       );
//     } else {
//       return SizedBox(
//         width: double.infinity,
//         child: CustomPaint(
//           painter: _HorizontalGradientWithTextPainter(
//             color: resolvedColor,
//             thickness: thickness,
//             style: style,
//             dashSpacing: dashSpacing,
//             dashWidth: dashWidth,
//             gradientColors: gradientColors,
//             addGlow: addGlow,
//             glowColor: glowColor ?? resolvedColor,
//             text: text,
//             textStyle: textStyle ?? defaultTextStyle,
//             textPadding: textPadding,
//             textMargin: 12.0.radius,
//             maxTextWidth: maxTextWidth,
//           ),
//           child: SizedBox(
//             height:
//                 (textStyle ?? defaultTextStyle).fontSize! +
//                 textPadding.vertical +
//                 30.height,
//             width: double.infinity,
//             child: Center(
//               child: _buildTextContainerForGradient(
//                 text,
//                 defaultTextStyle,
//                 resolvedColor,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//   }

//   Widget _buildTextContainerForGradient(
//     String text,
//     TextStyle defaultTextStyle,
//     Color resolvedColor,
//   ) {
//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: isVertical ? double.infinity : maxTextWidth,
//         maxHeight: isVertical ? maxTextWidth : double.infinity,
//       ),
//       margin: EdgeInsets.symmetric(
//         horizontal: isVertical ? 0 : 12.0.radius,
//         vertical: isVertical ? 12.0.radius : 0,
//       ),
//       padding: textPadding,
//       decoration: BoxDecoration(
//         color: textBackgroundColor ?? Colors.transparent,
//         borderRadius: BorderRadius.circular(textBorderRadius),
//         border: Border.all(
//           color: resolvedColor.withValues(alpha: 0.3),
//           width: 1.5.radius,
//         ),
//         boxShadow: addShadow
//             ? [
//                 BoxShadow(
//                   color: resolvedColor.withValues(alpha: 0.2),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ]
//             : null,
//       ),
//       child: Text(
//         text,
//         maxLines: 1,
//         textAlign: TextAlign.center,
//         overflow: TextOverflow.ellipsis,
//         style: textStyle ?? defaultTextStyle,
//       ),
//     );
//   }

//   Widget _buildTextContainer(
//     String text,
//     TextStyle defaultTextStyle,
//     Color resolvedColor,
//   ) {
//     return Flexible(
//       flex: 0,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: isVertical ? double.infinity : maxTextWidth,
//           maxHeight: isVertical ? maxTextWidth : double.infinity,
//         ),
//         margin: EdgeInsets.symmetric(
//           horizontal: isVertical ? 0 : 12.0.radius,
//           vertical: isVertical ? 12.0.radius : 0,
//         ),
//         padding: textPadding,
//         decoration: BoxDecoration(
//           color: textBackgroundColor ?? Colors.transparent,
//           borderRadius: BorderRadius.circular(textBorderRadius),
//           border: Border.all(
//             color: resolvedColor.withValues(alpha: 0.3),
//             width: 1.5.radius,
//           ),
//           boxShadow: addShadow
//               ? [
//                   BoxShadow(
//                     color: resolvedColor.withValues(alpha: 0.2),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Text(
//           text,
//           maxLines: 1,
//           textAlign: TextAlign.center,
//           overflow: TextOverflow.ellipsis,
//           style: textStyle ?? defaultTextStyle,
//         ),
//       ),
//     );
//   }

//   Widget _buildSimpleDivider(BuildContext context) {
//     final resolvedColor = color ?? context.customAppColors.grey300;
//     Widget dividerLine = CustomPaint(
//       painter: _DividerPainter(
//         color: resolvedColor,
//         thickness: thickness,
//         style: style,
//         dashSpacing: dashSpacing,
//         dashWidth: dashWidth,
//         gradientColors: gradientColors,
//         isVertical: isVertical,
//         addGlow: addGlow,
//         glowColor: glowColor ?? resolvedColor,
//       ),
//       child: isVertical
//           ? SizedBox(width: thickness, height: double.infinity)
//           : SizedBox(height: thickness, width: double.infinity),
//     );

//     if (addShadow) {
//       dividerLine = Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: resolvedColor.withValues(alpha: 0.3),
//               blurRadius: 4,
//               offset: isVertical ? const Offset(2, 0) : const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: dividerLine,
//       );
//     }

//     if (isVertical) {
//       return Padding(
//         padding: EdgeInsets.only(top: indent, bottom: endIndent),
//         child: dividerLine,
//       );
//     } else {
//       return Padding(
//         padding: EdgeInsets.only(left: indent, right: endIndent),
//         child: dividerLine,
//       );
//     }
//   }
// }

// enum DividerStyle { solid, dashed, dotted }

// class _DividerPainter extends CustomPainter {
//   final Color color;
//   final double thickness;
//   final DividerStyle style;
//   final double dashSpacing;
//   final double dashWidth;
//   final List<Color>? gradientColors;
//   final bool isVertical;
//   final bool addGlow;
//   final Color glowColor;

//   _DividerPainter({
//     required this.color,
//     required this.thickness,
//     required this.style,
//     required this.dashSpacing,
//     required this.dashWidth,
//     this.gradientColors,
//     required this.isVertical,
//     required this.addGlow,
//     required this.glowColor,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..strokeWidth = thickness
//       ..strokeCap = StrokeCap.round;

//     if (addGlow) {
//       final glowPaint = Paint()
//         ..strokeWidth = thickness + 4
//         ..strokeCap = StrokeCap.round
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

//       if (gradientColors != null && gradientColors!.length > 1) {
//         glowPaint.shader = _createGradient(
//           size,
//         ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//       } else {
//         glowPaint.color = glowColor.withValues(alpha: 0.4);
//       }

//       _drawLine(canvas, size, glowPaint);
//     }

//     if (gradientColors != null && gradientColors!.length > 1) {
//       paint.shader = _createGradient(
//         size,
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//     } else {
//       paint.color = color;
//     }

//     _drawLine(canvas, size, paint);
//   }

//   Gradient _createGradient(Size size) {
//     return LinearGradient(
//       begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
//       end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
//       colors: gradientColors!,
//     );
//   }

//   void _drawLine(Canvas canvas, Size size, Paint paint) {
//     if (isVertical) {
//       final startPoint = Offset(size.width / 2, 0);
//       final endPoint = Offset(size.width / 2, size.height);

//       switch (style) {
//         case DividerStyle.solid:
//           canvas.drawLine(startPoint, endPoint, paint);
//           break;
//         case DividerStyle.dashed:
//           _drawDashedLine(canvas, startPoint, endPoint, paint);
//           break;
//         case DividerStyle.dotted:
//           _drawDottedLine(canvas, startPoint, endPoint, paint);
//           break;
//       }
//     } else {
//       final startPoint = Offset(0, size.height / 2);
//       final endPoint = Offset(size.width, size.height / 2);

//       switch (style) {
//         case DividerStyle.solid:
//           canvas.drawLine(startPoint, endPoint, paint);
//           break;
//         case DividerStyle.dashed:
//           _drawDashedLine(canvas, startPoint, endPoint, paint);
//           break;
//         case DividerStyle.dotted:
//           _drawDottedLine(canvas, startPoint, endPoint, paint);
//           break;
//       }
//     }
//   }

//   void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//     final length = isVertical ? (end.dy - start.dy) : (end.dx - start.dx);
//     final dashCount = (length / (dashWidth + dashSpacing)).ceil();

//     if (isVertical) {
//       double currentY = start.dy;
//       for (var i = 0; i < dashCount && currentY < end.dy; i++) {
//         final dashEnd = (currentY + dashWidth).clamp(start.dy, end.dy);
//         if (dashEnd > currentY) {
//           canvas.drawLine(
//             Offset(start.dx, currentY),
//             Offset(start.dx, dashEnd),
//             paint,
//           );
//         }
//         currentY += dashWidth + dashSpacing;
//       }
//     } else {
//       double currentX = start.dx;
//       for (var i = 0; i < dashCount && currentX < end.dx; i++) {
//         final dashEnd = (currentX + dashWidth).clamp(start.dx, end.dx);
//         if (dashEnd > currentX) {
//           canvas.drawLine(
//             Offset(currentX, start.dy),
//             Offset(dashEnd, start.dy),
//             paint,
//           );
//         }
//         currentX += dashWidth + dashSpacing;
//       }
//     }
//   }

//   void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//     final length = isVertical ? (end.dy - start.dy) : (end.dx - start.dx);
//     final dotCount = (length / dashSpacing).ceil();

//     if (isVertical) {
//       double currentY = start.dy;
//       for (var i = 0; i < dotCount && currentY <= end.dy; i++) {
//         canvas.drawCircle(Offset(start.dx, currentY), thickness / 2, paint);
//         currentY += dashSpacing;
//       }
//     } else {
//       double currentX = start.dx;
//       for (var i = 0; i < dotCount && currentX <= end.dx; i++) {
//         canvas.drawCircle(Offset(currentX, start.dy), thickness / 2, paint);
//         currentX += dashSpacing;
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _DividerPainter oldDelegate) {
//     return oldDelegate.color != color ||
//         oldDelegate.thickness != thickness ||
//         oldDelegate.style != style ||
//         oldDelegate.dashSpacing != dashSpacing ||
//         oldDelegate.dashWidth != dashWidth ||
//         oldDelegate.gradientColors != gradientColors ||
//         oldDelegate.isVertical != isVertical ||
//         oldDelegate.addGlow != addGlow ||
//         oldDelegate.glowColor != glowColor;
//   }
// }

// class _ContinuousGradientDividerPainter extends CustomPainter {
//   final Color color;
//   final double thickness;
//   final DividerStyle style;
//   final double dashSpacing;
//   final double dashWidth;
//   final List<Color>? gradientColors;
//   final bool isVertical;
//   final bool addGlow;
//   final Color glowColor;
//   final bool showText;
//   final double totalHeight;
//   final double totalWidth;
//   final bool isLeftSide;

//   _ContinuousGradientDividerPainter({
//     required this.color,
//     required this.thickness,
//     required this.style,
//     required this.dashSpacing,
//     required this.dashWidth,
//     this.gradientColors,
//     required this.isVertical,
//     required this.addGlow,
//     required this.glowColor,
//     required this.showText,
//     required this.totalHeight,
//     required this.totalWidth,
//     // ignore: unused_element_parameter
//     this.isLeftSide = true,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..strokeWidth = thickness
//       ..strokeCap = StrokeCap.round;

//     if (addGlow) {
//       final glowPaint = Paint()
//         ..strokeWidth = thickness + 4
//         ..strokeCap = StrokeCap.round
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

//       if (gradientColors != null && gradientColors!.length > 1) {
//         glowPaint.shader = _createContinuousGradient(
//           size,
//         ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//       } else {
//         glowPaint.color = glowColor.withValues(alpha: 0.4);
//       }

//       _drawLine(canvas, size, glowPaint);
//     }

//     if (gradientColors != null && gradientColors!.length > 1) {
//       paint.shader = _createContinuousGradient(
//         size,
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//     } else {
//       paint.color = color;
//     }

//     _drawLine(canvas, size, paint);
//   }

//   Gradient _createContinuousGradient(Size size) {
//     return LinearGradient(
//       begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
//       end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
//       colors: gradientColors!,
//     );
//   }

//   void _drawLine(Canvas canvas, Size size, Paint paint) {
//     if (isVertical) {
//       final startPoint = Offset(size.width / 2, 0);
//       final endPoint = Offset(size.width / 2, size.height);

//       switch (style) {
//         case DividerStyle.solid:
//           canvas.drawLine(startPoint, endPoint, paint);
//           break;
//         case DividerStyle.dashed:
//           _drawDashedLine(canvas, startPoint, endPoint, paint);
//           break;
//         case DividerStyle.dotted:
//           _drawDottedLine(canvas, startPoint, endPoint, paint);
//           break;
//       }
//     } else {
//       final startPoint = Offset(0, size.height / 2);
//       final endPoint = Offset(size.width, size.height / 2);

//       switch (style) {
//         case DividerStyle.solid:
//           canvas.drawLine(startPoint, endPoint, paint);
//           break;
//         case DividerStyle.dashed:
//           _drawDashedLine(canvas, startPoint, endPoint, paint);
//           break;
//         case DividerStyle.dotted:
//           _drawDottedLine(canvas, startPoint, endPoint, paint);
//           break;
//       }
//     }
//   }

//   void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//     final length = isVertical ? (end.dy - start.dy) : (end.dx - start.dx);
//     final dashCount = (length / (dashWidth + dashSpacing)).ceil();

//     if (isVertical) {
//       double currentY = start.dy;
//       for (var i = 0; i < dashCount && currentY < end.dy; i++) {
//         final dashEnd = (currentY + dashWidth).clamp(start.dy, end.dy);
//         if (dashEnd > currentY) {
//           canvas.drawLine(
//             Offset(start.dx, currentY),
//             Offset(start.dx, dashEnd),
//             paint,
//           );
//         }
//         currentY += dashWidth + dashSpacing;
//       }
//     } else {
//       double currentX = start.dx;
//       for (var i = 0; i < dashCount && currentX < end.dx; i++) {
//         final dashEnd = (currentX + dashWidth).clamp(start.dx, end.dx);
//         if (dashEnd > currentX) {
//           canvas.drawLine(
//             Offset(currentX, start.dy),
//             Offset(dashEnd, start.dy),
//             paint,
//           );
//         }
//         currentX += dashWidth + dashSpacing;
//       }
//     }
//   }

//   void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//     final length = isVertical ? (end.dy - start.dy) : (end.dx - start.dx);
//     final dotCount = (length / dashSpacing).ceil();

//     if (isVertical) {
//       double currentY = start.dy;
//       for (var i = 0; i < dotCount && currentY <= end.dy; i++) {
//         canvas.drawCircle(Offset(start.dx, currentY), thickness / 2, paint);
//         currentY += dashSpacing;
//       }
//     } else {
//       double currentX = start.dx;
//       for (var i = 0; i < dotCount && currentX <= end.dx; i++) {
//         canvas.drawCircle(Offset(currentX, start.dy), thickness / 2, paint);
//         currentX += dashSpacing;
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _ContinuousGradientDividerPainter oldDelegate) {
//     return oldDelegate.color != color ||
//         oldDelegate.thickness != thickness ||
//         oldDelegate.style != style ||
//         oldDelegate.dashSpacing != dashSpacing ||
//         oldDelegate.dashWidth != dashWidth ||
//         oldDelegate.gradientColors != gradientColors ||
//         oldDelegate.isVertical != isVertical ||
//         oldDelegate.addGlow != addGlow ||
//         oldDelegate.glowColor != glowColor ||
//         oldDelegate.showText != showText ||
//         oldDelegate.totalHeight != totalHeight ||
//         oldDelegate.totalWidth != totalWidth ||
//         oldDelegate.isLeftSide != isLeftSide;
//   }
// }

// class _HorizontalGradientWithTextPainter extends CustomPainter {
//   final Color color;
//   final double thickness;
//   final DividerStyle style;
//   final double dashSpacing;
//   final double dashWidth;
//   final List<Color>? gradientColors;
//   final bool addGlow;
//   final Color glowColor;
//   final String text;
//   final TextStyle textStyle;
//   final EdgeInsets textPadding;
//   final double textMargin;
//   final double maxTextWidth;

//   _HorizontalGradientWithTextPainter({
//     required this.color,
//     required this.thickness,
//     required this.style,
//     required this.dashSpacing,
//     required this.dashWidth,
//     this.gradientColors,
//     required this.addGlow,
//     required this.glowColor,
//     required this.text,
//     required this.textStyle,
//     required this.textPadding,
//     required this.textMargin,
//     required this.maxTextWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final textPainter = TextPainter(
//       text: TextSpan(text: text, style: textStyle),
//       textDirection: ui.TextDirection.ltr,
//     );

//     textPainter.layout();

//     final textWidth =
//         (textPainter.width + textPadding.horizontal + (textMargin * 2)).clamp(
//           0,
//           maxTextWidth + textPadding.horizontal + (textMargin * 2),
//         );

//     final centerY = size.height / 2;
//     final leftEnd = (size.width - textWidth) / 2;
//     final rightStart = leftEnd + textWidth;

//     final paint = Paint()
//       ..strokeWidth = thickness
//       ..strokeCap = StrokeCap.round;

//     if (gradientColors != null && gradientColors!.length > 1) {
//       final gradient = LinearGradient(
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//         colors: gradientColors!,
//       );
//       paint.shader = gradient.createShader(
//         Rect.fromLTWH(0, 0, size.width, size.height),
//       );
//     } else {
//       paint.color = color;
//     }

//     if (addGlow) {
//       final glowPaint = Paint()
//         ..strokeWidth = thickness + 4
//         ..strokeCap = StrokeCap.round
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

//       if (gradientColors != null && gradientColors!.length > 1) {
//         final gradient = LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: gradientColors!,
//         );
//         glowPaint.shader = gradient.createShader(
//           Rect.fromLTWH(0, 0, size.width, size.height),
//         );
//       } else {
//         glowPaint.color = glowColor.withValues(alpha: 0.4);
//       }

//       _drawStyledLine(
//         canvas,
//         Offset(0, centerY),
//         Offset(leftEnd, centerY),
//         glowPaint,
//       );

//       _drawStyledLine(
//         canvas,
//         Offset(rightStart, centerY),
//         Offset(size.width, centerY),
//         glowPaint,
//       );
//     }

//     _drawStyledLine(
//       canvas,
//       Offset(0, centerY),
//       Offset(leftEnd, centerY),
//       paint,
//     );

//     _drawStyledLine(
//       canvas,
//       Offset(rightStart, centerY),
//       Offset(size.width, centerY),
//       paint,
//     );
//   }

//   void _drawStyledLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//     switch (style) {
//       case DividerStyle.solid:
//         canvas.drawLine(start, end, paint);
//         break;
//       case DividerStyle.dashed:
//         _drawDashedLine(canvas, start, end, paint);
//         break;
//       case DividerStyle.dotted:
//         _drawDottedLine(canvas, start, end, paint);
//         break;
//     }
//   }

//   void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//     final length = end.dx - start.dx;
//     if (length <= 0) return;

//     final dashCount = (length / (dashWidth + dashSpacing)).ceil();
//     double currentX = start.dx;

//     for (var i = 0; i < dashCount && currentX < end.dx; i++) {
//       final dashEnd = (currentX + dashWidth).clamp(start.dx, end.dx);

//       if (dashEnd > currentX) {
//         canvas.drawLine(
//           Offset(currentX, start.dy),
//           Offset(dashEnd, start.dy),
//           paint,
//         );
//       }

//       currentX += dashWidth + dashSpacing;
//     }
//   }

//   void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//     final length = end.dx - start.dx;
//     if (length <= 0) return;

//     final dotCount = (length / dashSpacing).ceil();
//     double currentX = start.dx;

//     for (var i = 0; i < dotCount && currentX <= end.dx; i++) {
//       canvas.drawCircle(Offset(currentX, start.dy), thickness / 2, paint);
//       currentX += dashSpacing;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _HorizontalGradientWithTextPainter oldDelegate) {
//     return oldDelegate.color != color ||
//         oldDelegate.thickness != thickness ||
//         oldDelegate.style != style ||
//         oldDelegate.dashSpacing != dashSpacing ||
//         oldDelegate.dashWidth != dashWidth ||
//         oldDelegate.gradientColors != gradientColors ||
//         oldDelegate.addGlow != addGlow ||
//         oldDelegate.glowColor != glowColor ||
//         oldDelegate.text != text ||
//         oldDelegate.textStyle != textStyle ||
//         oldDelegate.textPadding != textPadding ||
//         oldDelegate.textMargin != textMargin ||
//         oldDelegate.maxTextWidth != maxTextWidth;
//   }
// }
