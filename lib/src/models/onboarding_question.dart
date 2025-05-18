class OnboardingQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String? selectedOption;
  final bool isRequired;

  OnboardingQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.selectedOption,
    this.isRequired = true,
  });

  OnboardingQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    String? selectedOption,
    bool? isRequired,
  }) {
    return OnboardingQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      selectedOption: selectedOption ?? this.selectedOption,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}
