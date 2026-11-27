/// A task is To do, In progress or Done (spec F4).
enum TaskStatus {
  todo('todo'),
  inProgress('in_progress'),
  done('done');

  const TaskStatus(this.apiValue);

  /// The value the API uses.
  final String apiValue;

  static TaskStatus fromApi(String value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    throw FormatException('Unknown task status: $value');
  }
}

class BoardAssignee {
  const BoardAssignee({required this.id, required this.fullName});

  factory BoardAssignee.fromJson(Map<String, dynamic> json) =>
      BoardAssignee(id: json['id'] as String, fullName: json['full_name'] as String);

  final String id;
  final String fullName;

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'full_name': fullName};
}

/// One card of the board: a task with its owner and its deadline flags.
class BoardCardModel {
  const BoardCardModel({
    required this.id,
    required this.title,
    required this.status,
    required this.deadline,
    required this.assignee,
    required this.isOverdue,
    required this.dueTomorrow,
    required this.version,
  });

  factory BoardCardModel.fromJson(Map<String, dynamic> json) {
    final assignee = json['assignee'];
    return BoardCardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status: TaskStatus.fromApi(json['status'] as String),
      deadline: DateTime.parse(json['deadline'] as String),
      assignee: assignee is Map<String, dynamic> ? BoardAssignee.fromJson(assignee) : null,
      isOverdue: json['is_overdue'] as bool,
      dueTomorrow: json['due_tomorrow'] as bool,
      version: json['version'] as int,
    );
  }

  final String id;
  final String title;
  final TaskStatus status;
  final DateTime deadline;
  final BoardAssignee? assignee;

  /// Computed by the server in the team's time zone. Shown as a text label,
  /// never as a colour alone.
  final bool isOverdue;
  final bool dueTomorrow;

  /// For `409 TASK_CONFLICT` detection when the status is changed.
  final int version;

  BoardCardModel copyWith({
    TaskStatus? status,
    int? version,
    bool? isOverdue,
    bool? dueTomorrow,
  }) {
    return BoardCardModel(
      id: id,
      title: title,
      status: status ?? this.status,
      deadline: deadline,
      assignee: assignee,
      isOverdue: isOverdue ?? this.isOverdue,
      dueTomorrow: dueTomorrow ?? this.dueTomorrow,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'status': status.apiValue,
        'deadline': deadline.toUtc().toIso8601String(),
        'assignee': assignee?.toJson(),
        'is_overdue': isOverdue,
        'due_tomorrow': dueTomorrow,
        'version': version,
      };
}

class BoardProgress {
  const BoardProgress({required this.done, required this.total});

  final int done;
  final int total;

  /// 0 when there are no tasks.
  double get fraction => total == 0 ? 0 : done / total;
}

/// The board of a team: three columns and the team progress (spec F10).
class BoardModel {
  const BoardModel({required this.todo, required this.inProgress, required this.done});

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    List<BoardCardModel> cards(String key) => <BoardCardModel>[
          for (final item in json[key] as List<dynamic>)
            BoardCardModel.fromJson(item as Map<String, dynamic>),
        ];
    return BoardModel(
      todo: cards('todo'),
      inProgress: cards('in_progress'),
      done: cards('done'),
    );
  }

  final List<BoardCardModel> todo;
  final List<BoardCardModel> inProgress;
  final List<BoardCardModel> done;

  List<BoardCardModel> column(TaskStatus status) => switch (status) {
        TaskStatus.todo => todo,
        TaskStatus.inProgress => inProgress,
        TaskStatus.done => done,
      };

  /// Tasks done out of total, counted from the columns.
  BoardProgress get progress => BoardProgress(
        done: done.length,
        total: todo.length + inProgress.length + done.length,
      );

  BoardCardModel? cardById(String id) {
    for (final status in TaskStatus.values) {
      for (final card in column(status)) {
        if (card.id == id) return card;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'todo': <Map<String, dynamic>>[for (final c in todo) c.toJson()],
        'in_progress': <Map<String, dynamic>>[for (final c in inProgress) c.toJson()],
        'done': <Map<String, dynamic>>[for (final c in done) c.toJson()],
      };
}

/// The answer of `PATCH /tasks/{id}/status`.
class StatusChangeResult {
  const StatusChangeResult({
    required this.id,
    required this.status,
    required this.version,
    required this.completedAt,
    required this.isOverdue,
    required this.dueTomorrow,
  });

  factory StatusChangeResult.fromJson(Map<String, dynamic> json) {
    final completed = json['completed_at'];
    return StatusChangeResult(
      id: json['id'] as String,
      status: TaskStatus.fromApi(json['status'] as String),
      version: json['version'] as int,
      completedAt: completed is String ? DateTime.parse(completed) : null,
      isOverdue: json['is_overdue'] as bool,
      dueTomorrow: json['due_tomorrow'] as bool,
    );
  }

  final String id;
  final TaskStatus status;
  final int version;

  /// When the task was set to Done; shown in the stamp.
  final DateTime? completedAt;
  final bool isOverdue;
  final bool dueTomorrow;
}
