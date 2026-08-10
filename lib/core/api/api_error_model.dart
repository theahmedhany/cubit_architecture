import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_error_model.g.dart';

@JsonSerializable()
class ApiErrorModel {
  final String? message;
  final Map<String, List<String>>? errors;

  ApiErrorModel({this.message, this.errors});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorModelToJson(this);

  String get displayMessage {
    if (errors != null && errors!.isNotEmpty) {
      return getAllErrorMessages();
    }
    return message?.tr() ?? 'unknown_error_occurred'.tr();
  }

  String getAllErrorMessages({bool withFieldNames = false}) {
    if (errors == null || errors!.isEmpty) {
      return message?.tr() ?? 'unknown_error_occurred'.tr();
    }

    return errors!.entries
        .map((entry) {
          final field = entry.key;
          final messages = entry.value.join(', ');
          return withFieldNames ? '${field.tr()} : $messages' : messages;
        })
        .join('\n');
  }

  String get firstErrorMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.first.tr();
    }
    return message?.tr() ?? 'unknown_error_occurred'.tr();
  }
}
