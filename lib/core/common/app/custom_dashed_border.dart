// import 'dart:ui';

// import 'package:flutter/material.dart';

// class CustomDashedBorder extends CustomPainter {
//   final Color color;
//   final double strokeWidth;
//   final double dashWidth;
//   final double dashSpace;
//   final double cornerRadius;

//   CustomDashedBorder({
//     required this.color,
//     this.strokeWidth = 1.0,
//     this.dashWidth = 5.0,
//     this.dashSpace = 3.0,
//     this.cornerRadius = 8.0,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = color
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke;

//     final RRect rRect = RRect.fromRectAndRadius(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       Radius.circular(cornerRadius),
//     );

//     final Path path = Path()..addRRect(rRect);

//     Path dashPath = _dashPath(
//       path,
//       dashArray: CircularIntervalList<double>([dashWidth, dashSpace]),
//     );

//     canvas.drawPath(dashPath, paint);
//   }

//   Path _dashPath(
//     Path source, {
//     required CircularIntervalList<double> dashArray,
//   }) {
//     final Path dest = Path();
//     for (final PathMetric metric in source.computeMetrics()) {
//       double distance = 0.0;
//       bool draw = true;
//       while (distance < metric.length) {
//         final double len = dashArray.next;
//         if (draw) {
//           dest.addPath(
//             metric.extractPath(distance, distance + len),
//             Offset.zero,
//           );
//         }
//         distance += len;
//         draw = !draw;
//       }
//     }
//     return dest;
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class CircularIntervalList<T> {
//   CircularIntervalList(this._vals);
//   final List<T> _vals;
//   int _idx = 0;

//   T get next {
//     if (_idx >= _vals.length) {
//       _idx = 0;
//     }
//     return _vals[_idx++];
//   }
// }
