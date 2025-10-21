import '../models/availability_model.dart';

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;

  TimeSlot({required this.startTime, required this.endTime});

  Duration get duration => endTime.difference(startTime);

  bool overlapsWith(TimeSlot other) {
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }

  TimeSlot? intersection(TimeSlot other) {
    if (!overlapsWith(other)) return null;

    final intersectionStart = startTime.isAfter(other.startTime)
        ? startTime
        : other.startTime;
    final intersectionEnd = endTime.isBefore(other.endTime)
        ? endTime
        : other.endTime;

    return TimeSlot(startTime: intersectionStart, endTime: intersectionEnd);
  }

  @override
  String toString() {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
}

class SlotFinderService {
  static List<TimeSlot> findCommonSlots({
    required List<List<AvailabilityModel>> userAvailabilities,
    required Duration taskDuration,
  }) {
    if (userAvailabilities.isEmpty) return [];

    // Convert availability models to time slots
    List<List<TimeSlot>> userTimeSlots = userAvailabilities.map((
      availabilities,
    ) {
      return availabilities.map((availability) {
        return TimeSlot(
          startTime: availability.startTime,
          endTime: availability.endTime,
        );
      }).toList();
    }).toList();

    // Start with the first user's availability slots
    List<TimeSlot> commonSlots = userTimeSlots.first;

    // Find intersections with each subsequent user
    for (int i = 1; i < userTimeSlots.length; i++) {
      commonSlots = _findIntersections(commonSlots, userTimeSlots[i]);
      if (commonSlots.isEmpty) break; // No common slots found
    }

    // Filter slots that meet the minimum duration requirement
    commonSlots = commonSlots
        .where((slot) => slot.duration >= taskDuration)
        .toList();

    // Sort by start time
    commonSlots.sort((a, b) => a.startTime.compareTo(b.startTime));

    return commonSlots;
  }

  static List<TimeSlot> _findIntersections(
    List<TimeSlot> slots1,
    List<TimeSlot> slots2,
  ) {
    List<TimeSlot> intersections = [];

    for (TimeSlot slot1 in slots1) {
      for (TimeSlot slot2 in slots2) {
        TimeSlot? intersection = slot1.intersection(slot2);
        if (intersection != null) {
          intersections.add(intersection);
        }
      }
    }

    // Merge overlapping intersections
    return _mergeOverlappingSlots(intersections);
  }

  static List<TimeSlot> _mergeOverlappingSlots(List<TimeSlot> slots) {
    if (slots.isEmpty) return [];

    // Sort by start time
    slots.sort((a, b) => a.startTime.compareTo(b.startTime));

    List<TimeSlot> merged = [slots.first];

    for (int i = 1; i < slots.length; i++) {
      TimeSlot current = slots[i];
      TimeSlot last = merged.last;

      if (current.startTime.isBefore(last.endTime) ||
          current.startTime.isAtSameMomentAs(last.endTime)) {
        // Merge overlapping or adjacent slots
        merged[merged.length - 1] = TimeSlot(
          startTime: last.startTime,
          endTime: current.endTime.isAfter(last.endTime)
              ? current.endTime
              : last.endTime,
        );
      } else {
        // No overlap, add as new slot
        merged.add(current);
      }
    }

    return merged;
  }

  static List<TimeSlot> generateTimeSlots({
    required TimeSlot availabilitySlot,
    required Duration taskDuration,
    Duration? slotInterval,
  }) {
    slotInterval ??= const Duration(minutes: 15); // Default 15-minute intervals

    List<TimeSlot> slots = [];
    DateTime currentStart = availabilitySlot.startTime;

    while (currentStart.add(taskDuration).isBefore(availabilitySlot.endTime) ||
        currentStart
            .add(taskDuration)
            .isAtSameMomentAs(availabilitySlot.endTime)) {
      DateTime slotEnd = currentStart.add(taskDuration);

      slots.add(TimeSlot(startTime: currentStart, endTime: slotEnd));

      currentStart = currentStart.add(slotInterval);
    }

    return slots;
  }
}
