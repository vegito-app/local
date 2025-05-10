class ContractCall {
  final String contractAddress;
  final String contractName;
  final String functionName;
  final List<dynamic> functionArgs; // À adapter selon le type des args Clarity

  ContractCall({
    required this.contractAddress,
    required this.contractName,
    required this.functionName,
    required this.functionArgs,
  });

  String serialize() {
    // Exemple très simplifié de serialization à adapter pour Clarity
    return '$contractAddress.$contractName::$functionName(${functionArgs.join(",")})';
  }
}