// import 'dart:convert';
import 'dart:isolate';

// import 'package:collection/collection.dart';
import 'dart:developer' as devtools show log;

import 'package:aoc_manager/solutions/generic_solution.dart';

const limit = 100000;

class FileEntry {
  final String _name;
  final int _size;

  FileEntry({required String name, int size = 0})
      : _name = name,
        _size = size;

  String get name => _name;
  int get size => _size;
}

class DirEntry extends FileEntry {
  DirEntry({required super.name});

  List<FileEntry> directory = [];

  @override
  int get size => directory.fold<int>(0, (acc, f) => acc + f.size);
}

mixin DirManager {
  List<DirEntry> path = [];

  void cd(List<String> words) {
    final newDirName = words[2];
    switch (newDirName) {
      case '/':
        path = [path[0]];
      case '..':
        if (path.length > 1) {
          path.removeLast();
        }
      default:
        DirEntry? newDir;
        for (final entry in path.last.directory) {
          if (entry.name == newDirName) {
            if (entry is DirEntry) {
              newDir = entry;
            } else {
              devtools.log('$newDirName is not a directory');
            }
            break;
          }
        }
        if (newDir != null) {
          path.add(newDir);
        } else {
          devtools.log('$newDirName not found');
        }
    }
  }

  void processCommand(String line) {
    final words = line.split(' ');
    switch (words[1]) {
      case 'cd':
        cd(words);
      case 'ls':
        break;
      default:
        devtools.log('Invalid command: "${words[1]}');
    }
  }

  void addDir(String line) {
    final words = line.split(' ');
    path.last.directory.add(DirEntry(name: words[1]));
  }

  void addFile(String line) {
    final words = line.split(' ');
    path.last.directory
        .add(FileEntry(name: words[1], size: int.parse(words[0])));
  }

  Future<void> buildDirectory(Stream<String> lines) async {
    final root = DirEntry(name: '/');
    path = [root];

    await for (final line in lines) {
      switch (line[0]) {
        case '\$':
          processCommand(line);
        case 'd':
          addDir(line);
        default:
          addFile(line);
      }
    }
  }

  void dirTree(
      {required DirEntry root,
      int indent = 0,
      required void Function(String) say}) {
    void indentPrint({String message = '', int indent = 0}) {
      final spaces = ''.padRight(indent, ' ');
      say('$spaces$message');
    }

    indentPrint(
        message: '- ${root.name} (dir, size=${root.size})', indent: indent);
    for (final file in root.directory) {
      if (file is DirEntry) {
        dirTree(root: file, indent: indent + 2, say: say);
      } else {
        indentPrint(
            message: '- ${file.name} (file, size=${file.size})',
            indent: indent + 2);
      }
    }
  }

  int dirUnderLimit(DirEntry root) {
    int total = 0;
    final thisDirSize = root.size;
    if (thisDirSize <= limit) {
      total = thisDirSize;
    }
    for (final dir in root.directory) {
      if (dir is DirEntry) {
        total += dirUnderLimit(dir);
      }
    }
    return total;
  }

  int findSmallestDir(
      {required DirEntry root,
      required int requiredSpace,
      required int smallestSoFar}) {
    int smallest = smallestSoFar;
    final thisDirSize = root.size;
    if (thisDirSize >= requiredSpace && thisDirSize < smallestSoFar) {
      smallest = thisDirSize;
    }

    for (final dir in root.directory) {
      if (dir is DirEntry) {
        smallest = findSmallestDir(
          root: dir,
          requiredSpace: requiredSpace,
          smallestSoFar: smallest,
        );
      }
    }

    return smallest;
  }
}

class Day07P1 extends Solution with DirManager {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 7 Part 1');

    await buildDirectory(lines());

    say('The answer is ${dirUnderLimit(path[0])}');
  }
}

const diskSize = 70000000;
const requiredSpace = 30000000;

class Day07P2 extends Solution with DirManager {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 7 Part 2');

    await buildDirectory(lines());

    final availableSpace = diskSize - path[0].size;
    final extraSpaceRequired = requiredSpace - availableSpace;

    say('The answer is ${findSmallestDir(
      root: path[0],
      requiredSpace: extraSpaceRequired,
      smallestSoFar: path[0].size,
    )}');
  }
}
