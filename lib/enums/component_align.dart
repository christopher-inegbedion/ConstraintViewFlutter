enum ComponentAlign { left, center, right }

String componentAlignToString(ComponentAlign alignment) {
  switch (alignment) {
    case ComponentAlign.center:
      return "center";
      break;
    case ComponentAlign.left:
      return "left";
      break;
    case ComponentAlign.right:
      return "right";
      break;
    default:
      return null;
  }
}
