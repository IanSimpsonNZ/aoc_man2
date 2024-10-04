import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ButtonPanel extends StatelessWidget {
  const ButtonPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayBloc, DayState>(builder: (context, state) {
      if (state is DayReady) {
        return Wrap(
          spacing: 65,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: state.isRunning
                  ? null
                  : () {
                      final dayEventHandler = context.read<DayBloc>();
                      dayEventHandler.add(DayRunEvent(dayEventHandler));
                    },
              child: const SizedBox(
                width: 50,
                child: Center(
                  child: Text('Run'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: !state.isRunning
                  ? null
                  : () {
                      context.read<DayBloc>().add(const DayPauseEvent());
                    },
              child: const SizedBox(
                width: 50,
                child: Center(
                  child: Text('Pause'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: !state.isRunning
                  ? null
                  : () {
                      context.read<DayBloc>().add(const DayHaltEvent());
                    },
              child: const SizedBox(
                width: 50,
                child: Center(
                  child: Text('Halt'),
                ),
              ),
            ),
          ],
        );
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
