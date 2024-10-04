import 'package:aoc_manager/constants/day_constants.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';

class DayPanel extends StatefulWidget {
  const DayPanel({super.key});

  @override
  State<DayPanel> createState() => _DayPanelState();
}

class _DayPanelState extends State<DayPanel> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayBloc, DayState>(builder: (context, state) {
      if (state is DayReady) {
        return Opacity(
          opacity: state.isRunning ? 0.5 : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Day', style: Theme.of(context).textTheme.headlineSmall),
              NumberPicker(
                value: state.dayNum,
                minValue: minDay,
                maxValue: maxDay,
                step: 1,
                haptics: true,
                textStyle: Theme.of(context).textTheme.bodyMedium,
                selectedTextStyle: Theme.of(context).textTheme.headlineSmall,
                itemHeight: 50.0,
                itemWidth: 50.0,
                onChanged: (value) {
                  context.read<DayBloc>().add(DayChangeDayEvent(value));
                },
              ),
              IntrinsicWidth(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RadioListTile<int>(
                        title: Text(
                          'Part 1',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        value: 1,
                        groupValue: state.partNum,
                        dense: true,
                        onChanged: (int? value) {
                          context
                              .read<DayBloc>()
                              .add(DayChangePartEvent(value ?? 1));
                        }),
                    RadioListTile<int>(
                        title: Text(
                          'Part 2',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        value: 2,
                        groupValue: state.partNum,
                        dense: true,
                        onChanged: (int? value) {
                          context
                              .read<DayBloc>()
                              .add(DayChangePartEvent(value ?? 1));
                        }),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
