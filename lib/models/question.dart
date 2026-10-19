enum Type { multiple, boolean }

enum Difficulty { easy, medium, hard }

class Question {
  final String? categoryName;
  final Type? type;
  final Difficulty? difficulty;
  final String? question;
  final String? correctAnswer;
  final List<dynamic>? incorrectAnswers;
  final String? optionType;
  final String? mediaLink;
  final String? mediaType;
  final String? examId;

  Question({
    this.categoryName,
    this.type,
    this.difficulty,
    this.question,
    this.correctAnswer,
    this.incorrectAnswers,
    this.optionType,
    this.mediaLink,
    this.mediaType,
    this.examId,
  });

  Question.fromMap(Map<String, dynamic> data)
      : categoryName = data["category"],
        type = data["type"] == "multiple" ? Type.multiple : Type.boolean,
        difficulty = data["difficulty"] == "easy"
            ? Difficulty.easy
            : data["difficulty"] == "medium"
                ? Difficulty.medium
                : Difficulty.hard,
        question = data["question"],
        correctAnswer = data["correct_answer"],
        optionType = data["option_type"],
        mediaLink = data["media_link"],
        mediaType = data["media_type"],
        examId = data["exam_id"],
        incorrectAnswers = data["incorrect_answers"];

  static List<Question> fromData(List<Map<String, dynamic>> data) {
    return data.map((question) => Question.fromMap(question)).toList();
  }
}
