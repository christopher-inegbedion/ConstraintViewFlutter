class ViewMargin {
  double top;
  double bottom;
  double left;
  double right;

  ViewMargin(this.top, this.bottom, this.left, this.right);

  factory ViewMargin.fromString(String margin) {
    List marginArray = margin.split(",");
    return ViewMargin(
        double.parse("${marginArray[0]}"),
        double.parse("${marginArray[1]}"),
        double.parse("${marginArray[2]}"),
        double.parse("${marginArray[3]}"));
  }
}
