import 'package:flutter/material.dart';
import '../../models/local_quiz.dart';
import '../../services/quiz_service.dart';

class QuizEditorScreen extends StatefulWidget {
  final String lessonId;
  final String contentTitle;
  final LocalQuiz? existingQuiz;

  const QuizEditorScreen({
    super.key,
    required this.lessonId,
    required this.contentTitle,
    this.existingQuiz,
  });

  @override
  State<QuizEditorScreen> createState() => _QuizEditorScreenState();
}

class _QuizEditorScreenState extends State<QuizEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<QuestionEditor> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.existingQuiz?.title ?? '';
    if (widget.existingQuiz != null) {
      _questions.addAll(
        widget.existingQuiz!.questions.map(
          (q) => QuestionEditor(
            text: q.text,
            options: List.from(q.options),
            correctOptionIndex: q.correctOptionIndex,
            explanation: q.explanation ?? '',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionEditor(
        text: '',
        options: ['', '', '', ''],
        correctOptionIndex: 0,
        explanation: '',
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final questions = _questions
          .map((q) => LocalQuizQuestion(
                text: q.text,
                options: q.options,
                correctOptionIndex: q.correctOptionIndex,
                explanation: q.explanation.isEmpty ? null : q.explanation,
              ))
          .toList();

      if (widget.existingQuiz != null) {
        await QuizService.instance.updateQuiz(
          localId: widget.existingQuiz!.id.toString(),
          title: _titleController.text,
          questions: questions,
        );
      } else {
        await QuizService.instance.createQuiz(
          subjectId: widget.lessonId,
          title: _titleController.text,
          questions: questions,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando cuestionario: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingQuiz != null
            ? 'Editar Cuestionario'
            : 'Nuevo Cuestionario'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título del Cuestionario',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(
                          _questions.length,
                          (index) => _buildQuestionEditor(index),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Pregunta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _saveQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Guardar Cuestionario'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionEditor(int index) {
    final question = _questions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: question.text,
                    decoration: InputDecoration(
                      labelText: 'Pregunta ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la pregunta';
                      }
                      return null;
                    },
                    onChanged: (value) => question.text = value,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeQuestion(index),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (optionIndex) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: optionIndex,
                      groupValue: question.correctOptionIndex,
                      onChanged: (value) {
                        setState(() {
                          question.correctOptionIndex = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: question.options[optionIndex],
                        decoration: InputDecoration(
                          labelText:
                              'Opción ${String.fromCharCode(65 + optionIndex)}',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la opción';
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            question.options[optionIndex] = value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: question.explanation,
              decoration: const InputDecoration(
                labelText: 'Explicación (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => question.explanation = value,
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionEditor {
  String text;
  List<String> options;
  int correctOptionIndex;
  String explanation;

  QuestionEditor({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    this.explanation = '',
  });
}
