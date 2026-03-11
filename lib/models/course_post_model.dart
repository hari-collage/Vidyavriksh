import 'dart:typed_data';

class CoursePost {
  final String id;
  final String teacherEmail;
  final String teacherName;
  final String courseName;
  final String courseDescription;
  final String textBlog;
  final String videoLink;
  final String quizType;
  final String quizContent;
  final String pdfFileName;
  final Uint8List? pdfBytes;

  CoursePost({
    required this.id,
    required this.teacherEmail,
    required this.teacherName,
    required this.courseName,
    required this.courseDescription,
    required this.textBlog,
    required this.videoLink,
    required this.quizType,
    required this.quizContent,
    required this.pdfFileName,
    required this.pdfBytes,
  });
}
