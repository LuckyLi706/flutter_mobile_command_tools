/// 模拟操作类型
enum SimOperationType { SWIPE, TEXT, TAP, EVENT, ADB, OTHER }

extension SimOperationTypeValue on SimOperationType {
  String get value {
    String _value = '';
    switch (this) {
      case SimOperationType.SWIPE:
        _value = '滑动';
        break;
      case SimOperationType.TEXT:
        _value = '输入';
        break;
      case SimOperationType.TAP:
        _value = '点击';
        break;
      case SimOperationType.EVENT:
        _value = '事件';
        break;
      case SimOperationType.ADB:
        _value = 'ADB';
        break;
      case SimOperationType.OTHER:
        _value = 'OTHER';
        break;
      // case SimOperationType.NONE:
      //   _value = 'NONE';
      //   break;
      default:
    }
    return _value;
  }

  // SimOperationType get type {
  //   switch (this.value) {
  //     case "滑动":
  //       return SimOperationType.SWIPE;
  //     case "输入":
  //       return SimOperationType.TEXT;
  //     case "点击":
  //       return SimOperationType.TAP;
  //     case "事件":
  //       return SimOperationType.EVENT;
  //     case "ADB":
  //       return SimOperationType.ADB;
  //     case "OTHER":
  //       return SimOperationType.OTHER;
  //     default:
  //   }
  //   return SimOperationType.SWIPE;
  // }
}

enum SwipeType {
  /// 上滑
  SWIPE_TOP,

  /// 下滑
  SWIPE_BOTTOM,

  /// 左滑
  SWIPE_LEFT,

  /// 右滑
  SWIPE_RIGHT,

  /// 自定义
  SWIPE_CUSTOM
}

extension SwipeTypeValue on SwipeType {
  String get value {
    String _value = '';
    switch (this) {
      case SwipeType.SWIPE_TOP:
        _value = '上滑';
        break;
      case SwipeType.SWIPE_BOTTOM:
        _value = '下滑';
        break;
      case SwipeType.SWIPE_LEFT:
        _value = '左滑';
        break;
      case SwipeType.SWIPE_RIGHT:
        _value = '右滑';
        break;
      case SwipeType.SWIPE_LEFT:
        _value = '自定义';
        break;
      default:
    }
    return _value;
  }
}
