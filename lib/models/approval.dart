class Approval {
  final bool isApproved;
  final String? rejectionReason;

  const Approval({required this.isApproved, this.rejectionReason});

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      isApproved: json['isApproved'] as bool,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'isApproved': isApproved, 'rejectionReason': rejectionReason};
  }
}
