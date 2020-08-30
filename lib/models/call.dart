class Call {
  final String callerId;
  final String recieverId;
  final DateTime timestamp;

  String callerImageUrl;

  Call({
    this.callerId,
    this.recieverId,
    this.timestamp,
    this.callerImageUrl,
  });
}
