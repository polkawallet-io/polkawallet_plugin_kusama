import 'package:json_annotation/json_annotation.dart';

part 'txData.g.dart';

@JsonSerializable()
class TxRewardData extends _TxRewardData {
  static TxRewardData fromJson(Map<String, dynamic> json) =>
      _$TxRewardDataFromJson(json);
}

abstract class _TxRewardData {
  @JsonKey(name: 'block_num')
  int? blockNum = 0;

  @JsonKey(name: 'block_timestamp')
  int? blockTimestamp = 0;

  String? amount = "";

  @JsonKey(name: 'event_id')
  String? eventId = "";

  @JsonKey(name: 'event_idx')
  int? eventIdx;

  @JsonKey(name: 'event_index')
  String? eventIndex;

  @JsonKey(name: 'extrinsic_hash')
  String? extrinsicHash = "";

  @JsonKey(name: 'extrinsic_idx')
  int? extrinsicIdx;

  @JsonKey(name: 'module_id')
  String? moduleId = "";

  @JsonKey(name: 'extrinsic_index')
  String? txNumber = "";

  @JsonKey(name: 'slash_kton')
  String? slashKton = "";

  String? params = "";
}
