// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
import "package:async/async.dart" show StreamQueue;

import 'package:aoc_manager/solutions/generic_solution.dart';
//import 'package:aoc_manager/solutions/helpers/coord.dart';

import 'dart:developer' as devtools show log;

enum CompareResult {
  undecided,
  valid,
  invalid,
}

class MessageElement {
  int? number;
  List<MessageElement>? list;

  MessageElement({this.number, this.list});

  String print() {
    String result = '';
    if (number == null && list == null) return result;
    if (number != null && list != null) result = 'Number and list : $number + ';
    if (number == null) {
      result = '[';
      for (final element in list!) {
        result = '$result${element.print()}';
      }
      if (result.endsWith(',')) {
        result = result.substring(0, result.length - 1);
      }
      result = '$result],';
    } else {
      result = '$number,';
    }
    return result;
  }
}

class ParseResult {
  List<MessageElement> elements;
  int cursorIndex;

  ParseResult({required this.elements, required this.cursorIndex});
}

ParseResult parseMessageStr(int cursorStartIndex, String messageStr) {
  var result = ParseResult(elements: [], cursorIndex: cursorStartIndex);
  String numStr = '';
  while (result.cursorIndex < messageStr.length) {
    switch (messageStr[result.cursorIndex]) {
      case ',':
        // This could be after a number or after a sub-list
        // if it is after a list just ignore it.
        // if it is ater a number (ie numStr is not empty) store the number
        if (numStr.isNotEmpty) {
          final num = int.tryParse(numStr);
          if (num != null) {
            result.elements.add(MessageElement(number: num));
          } else {
            devtools.log('Tried to parse non-integer: "$numStr"');
          }
          numStr = '';
        }
        result.cursorIndex++;
      case ']':
        // We're at the end of the (sub)list
        // If we have picked up a final number, store it
        // then return the list
        if (numStr.isNotEmpty) {
          final num = int.tryParse(numStr);
          if (num != null) {
            result.elements.add(MessageElement(number: num));
          } else {
            devtools.log('Tried to parse non-integer: "$numStr"');
          }
          numStr = '';
        }
        result.cursorIndex++;
        return result;
      case '[':
        // We have started a new sublist.
        final subMessageResult =
            parseMessageStr(result.cursorIndex + 1, messageStr);
        result.elements.add(MessageElement(list: subMessageResult.elements));
        result.cursorIndex = subMessageResult.cursorIndex;
      default:
        numStr = '$numStr${messageStr[result.cursorIndex]}';
        result.cursorIndex++;
    }
  }
  if (numStr.isNotEmpty) {
    devtools.log('Unparsed number at end of message');
  }
  return result;
}

class Message {
  List<MessageElement> messageList = [];
  void Function(String) say;

  Message(String strMessage, this.say) {
    if (strMessage.length < 2) return;

    messageList = parseMessageStr(1, strMessage).elements;
  }

  CompareResult _validateLists(
      {required List<MessageElement> leftList,
      required List<MessageElement> rightList}) {
    for (final (idx, left) in leftList.indexed) {
      // End of right list before end of left list
      if (idx >= rightList.length) {
        return CompareResult.invalid;
      }

      final right = rightList[idx];
      assert(!(left.number == null && left.list == null));
      assert(!(right.number == null && right.list == null));

      CompareResult result = CompareResult.undecided;
      // Two integers
      if (left.number != null && right.number != null) {
        if (left.number! < right.number!) {
          result = CompareResult.valid;
        } else if (left.number! > right.number!) {
          result = CompareResult.invalid;
        }
        // drop out of this if statement if left and right are equal
      } else if (left.number != null && right.number == null) {
        // Integer on left, list on right
        final newLeft = [left];
        result = _validateLists(leftList: newLeft, rightList: right.list!);
      } else if (left.number == null && right.number != null) {
        // List left, integer right
        final newRight = [right];
        result = _validateLists(leftList: left.list!, rightList: newRight);
      } else {
        // Two lists
        result = _validateLists(leftList: left.list!, rightList: right.list!);
      }
      if (result != CompareResult.undecided) {
        return result;
      }
      // No result yet, loop to next item
    }

    // End of left list with no result
    if (leftList.length < rightList.length) {
      return CompareResult.valid;
    }
    // Finally - both lists are ssame length and no deciding element
    return CompareResult.undecided;
  }

  CompareResult validateWith(Message right) {
    if (messageList.isEmpty && right.messageList.isEmpty) {
      return CompareResult.undecided;
    }
    if (messageList.isEmpty && right.messageList.isNotEmpty) {
      return CompareResult.valid;
    }
    if (messageList.isNotEmpty && right.messageList.isEmpty) {
      return CompareResult.invalid;
    }

    return _validateLists(leftList: messageList, rightList: right.messageList);
  }

  String print() {
    String result = '[';
    for (final element in messageList) {
      result = '$result${element.print()}';
    }
    if (result.endsWith(',')) {
      result = result.substring(0, result.length - 1);
    }
    result = '$result]';
    return result;
  }
}

class Day13P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 13 Part 1');

    final messages = StreamQueue<String>(lines());

    int pairNum = 0;
    int answer = 0;
    while (await messages.hasNext) {
      pairNum++;
      final left = Message(await messages.next, say);
      final right = Message(await messages.next, say);
      if (await messages.hasNext) {
        // skip the blank line
        await messages.skip(1);
      }
      if (left.validateWith(right) == CompareResult.valid) answer += pairNum;
    }

    await messages.cancel();
    say('The answer is $answer');
  }
}

class Day13P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 13 Part 2');

    var messages = await lines()
        .where((s) => s.isNotEmpty)
        .map((s) => Message(s, say))
        .toList();
    messages.add(Message('[[2]]', say));
    messages.add(Message('[[6]]', say));

    for (int i = 0; i < messages.length - 1; i++) {
      bool swapped = false;
      for (int j = 0; j < messages.length - 1 - i; j++) {
        if (messages[j].validateWith(messages[j + 1]) != CompareResult.valid) {
          final tmp = messages[j];
          messages[j] = messages[j + 1];
          messages[j + 1] = tmp;
          swapped = true;
        }
      }

      if (!swapped) {
        break;
      }
    }

    int twoPos = 0;
    int sixPos = 0;
    for (final (idx, mess) in messages.indexed) {
      final message = mess.print();
      say(message);
      if (message == '[[2]]') twoPos = idx + 1;
      if (message == '[[6]]') sixPos = idx + 1;
    }

    say('The answer is ${twoPos * sixPos}');
  }
}
