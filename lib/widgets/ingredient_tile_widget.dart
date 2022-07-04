import 'package:flutter/material.dart';

class IngredientTile extends StatelessWidget {
  final List<String> ingredient;
  const IngredientTile(this.ingredient, {Key? key})
      : assert(ingredient.length == 2),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        textDirection: TextDirection.ltr,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              ingredient.first,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.only(
                top: 12,
                left: 6,
                right: 6,
              ),
              alignment: Alignment.bottomLeft,
              child: CustomPaint(
                  child: Container(), painter: DrawDottedHorizontalLine()),
            ),
          ),
          Text(
            ingredient.last,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class DrawDottedHorizontalLine extends CustomPainter {
  late Paint _paint;
  DrawDottedHorizontalLine() {
    _paint = Paint();
    _paint.color = const Color(0xFF356859);
    _paint.strokeWidth = 2; //dots thickness
    _paint.strokeCap = StrokeCap.round; //dots corner edges
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (double i = 0; i < size.width; i = i + 5) {
      canvas.drawLine(Offset(i, 0.0), Offset(i + 1, 0.0), _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
