import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorPanel extends StatefulWidget {
  const ErrorPanel({super.key});

  @override
  State<ErrorPanel> createState() => _ErrorPanelState();
}

class _ErrorPanelState extends State<ErrorPanel> {
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
            itemCount: state.errorMessages.length,
            itemBuilder: (context, index) {
              final line = state.errorMessages.elementAt(index);
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
