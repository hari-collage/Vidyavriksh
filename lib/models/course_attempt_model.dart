class CourseAttempt {
  final String courseId;
  final String studentEmail;
  final String studentName;
  final bool courseAttempted;
  final bool quizAttempted;
  final int marks;

  CourseAttempt({
    required this.courseId,
    required this.studentEmail,
    required this.studentName,
    required this.courseAttempted,
    required this.quizAttempted,
    required this.marks,
  });

  CourseAttempt copyWith({
    bool? courseAttempted,
    bool? quizAttempted,
    int? marks,
  }) {
    return CourseAttempt(
      courseId: courseId,
      studentEmail: studentEmail,
      studentName: studentName,
      courseAttempted: courseAttempted ?? this.courseAttempted,
      quizAttempted: quizAttempted ?? this.quizAttempted,
      marks: marks ?? this.marks,
    );
  }
}
