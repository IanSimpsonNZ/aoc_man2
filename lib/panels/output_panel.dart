import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class OutputPanel extends StatefulWidget {
  const OutputPanel({super.key});

  @override
  State<OutputPanel> createState() => _OutputPanelState();
}

class _OutputPanelState extends State<OutputPanel> {
  final ScrollController _controller = ScrollController();
  void _scrollToBottom() {
    if (_controller.positions.isNotEmpty) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayBloc, DayState>(
      builder: (context, state) {
        if (state is DayReady) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
          return ListView.builder(
            controller: _controller,
            prototypeItem: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              child: Text(
                'Hello',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            padding: const EdgeInsets.all(8),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final line = state.messages.elementAt(index);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                child: SelectableText(
                  line,
                  maxLines: 1,
                  style: GoogleFonts.robotoMono(
                      textStyle: Theme.of(context).textTheme.bodyLarge),
                ),
              );
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
