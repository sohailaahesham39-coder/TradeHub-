import 'package:intl/intl.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  String imageUrl; // Changed from final to allow modification
  final double ticketPrice;
  final int totalAttendees;
  final String organizerId;
  final String organizerName;
  final List<String>? tags;
  final String? website;
  final List<Map<String, dynamic>>? speakers;
  final List<Map<String, dynamic>>? schedule;
  final bool isVirtual;
  final String? virtualMeetingLink;
  final bool isBookmarked;
  final int? remainingTickets;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.ticketPrice,
    required this.totalAttendees,
    required this.organizerId,
    required this.organizerName,
    this.tags,
    this.website,
    this.speakers,
    this.schedule,
    this.isVirtual = false,
    this.virtualMeetingLink,
    this.isBookmarked = false,
    this.remainingTickets,
  });

  String getFormattedPrice(String currency) {
    return '$currency${ticketPrice.toStringAsFixed(2)}';
  }

  String getFormattedDate() {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String getFormattedTime() {
    return DateFormat('hh:mm a').format(date);
  }

  String getFormattedDay() {
    return DateFormat('EEEE').format(date);
  }

  int getDaysRemaining() {
    final now = DateTime.now();
    return date.difference(now).inDays;
  }

  bool isUpcoming() {
    final now = DateTime.now();
    return date.isAfter(now);
  }

  bool isPast() {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  bool isToday() {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  bool isSoldOut() {
    return remainingTickets != null && remainingTickets! <= 0;
  }

  String getShortDescription([int maxLength = 100]) {
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength - 3)}...';
  }

  bool get hasVirtualMeetingLink {
    return virtualMeetingLink != null && virtualMeetingLink!.isNotEmpty;
  }

  // Create a copy with updated attributes
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? imageUrl,
    double? ticketPrice,
    int? totalAttendees,
    String? organizerId,
    String? organizerName,
    List<String>? tags,
    String? website,
    List<Map<String, dynamic>>? speakers,
    List<Map<String, dynamic>>? schedule,
    bool? isVirtual,
    String? virtualMeetingLink,
    bool? isBookmarked,
    int? remainingTickets,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      totalAttendees: totalAttendees ?? this.totalAttendees,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      tags: tags ?? this.tags,
      website: website ?? this.website,
      speakers: speakers ?? this.speakers,
      schedule: schedule ?? this.schedule,
      isVirtual: isVirtual ?? this.isVirtual,
      virtualMeetingLink: virtualMeetingLink ?? this.virtualMeetingLink,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      remainingTickets: remainingTickets ?? this.remainingTickets,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String,
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      totalAttendees: json['totalAttendees'] as int,
      organizerId: json['organizerId'] as String,
      organizerName: json['organizerName'] as String,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      website: json['website'] as String?,
      speakers: json['speakers'] != null
          ? List<Map<String, dynamic>>.from(json['speakers'] as List)
          : null,
      schedule: json['schedule'] != null
          ? List<Map<String, dynamic>>.from(json['schedule'] as List)
          : null,
      isVirtual: json['isVirtual'] as bool? ?? false,
      virtualMeetingLink: json['virtualMeetingLink'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      remainingTickets: json['remainingTickets'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'ticketPrice': ticketPrice,
      'totalAttendees': totalAttendees,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'tags': tags,
      'website': website,
      'speakers': speakers,
      'schedule': schedule,
      'isVirtual': isVirtual,
      'virtualMeetingLink': virtualMeetingLink,
      'isBookmarked': isBookmarked,
      'remainingTickets': remainingTickets,
    };
  }
}