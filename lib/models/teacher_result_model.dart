class StudentMark {
  final String studentName;
  final int marks;

  StudentMark({
    required this.studentName,
    required this.marks,
  });
}

class TeacherResultSummary {
  final int studentsAttemptedCourse;
  final int studentsAttemptedQuiz;
  final int totalMarks;
  final List<StudentMark> studentMarks;

  TeacherResultSummary({
    required this.studentsAttemptedCourse,
    required this.studentsAttemptedQuiz,
    required this.totalMarks,
    required this.studentMarks,
  });
}
