class UserReputation {
  final String userId;
  final bool optIn;
  final double score;
  final int votes;

  UserReputation({
    required this.userId,
    required this.optIn,
    required this.score,
    required this.votes,
  });

  factory UserReputation.fromMap(String id, Map<String, dynamic> data) {
    return UserReputation(
      userId: id,
      optIn: data['reputationOptIn'] as bool,
      score: data['reputationScore'] as double,
      votes: data['reputationVotes'] as int,
    );
  }

  factory UserReputation.empty({required String userId}) {
    return UserReputation(
      userId: userId,
      optIn: false,
      score: 0.0,
      votes: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reputationOptIn': optIn,
      'reputationScore': score,
      'reputationVotes': votes,
    };
  }
}
