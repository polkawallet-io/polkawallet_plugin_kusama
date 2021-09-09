// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'txData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxRewardData _$TxRewardDataFromJson(Map<String, dynamic> json) {
  return TxRewardData()
    ..blockNum = json['block_num'] as int?
    ..blockTimestamp = json['block_timestamp'] as int?
    ..amount = json['amount'] as String?
    ..eventId = json['event_id'] as String?
    ..eventIdx = json['event_idx'] as int?
    ..eventIndex = json['event_index'] as String?
    ..extrinsicHash = json['extrinsic_hash'] as String?
    ..extrinsicIdx = json['extrinsic_idx'] as int?
    ..moduleId = json['module_id'] as String?
    ..txNumber = json['extrinsic_index'] as String?
    ..slashKton = json['slash_kton'] as String?
    ..params = json['params'] as String?;
}

Map<String, dynamic> _$TxRewardDataToJson(TxRewardData instance) =>
    <String, dynamic>{
      'block_num': instance.blockNum,
      'block_timestamp': instance.blockTimestamp,
      'amount': instance.amount,
      'event_id': instance.eventId,
      'event_idx': instance.eventIdx,
      'event_index': instance.eventIndex,
      'extrinsic_hash': instance.extrinsicHash,
      'extrinsic_idx': instance.extrinsicIdx,
      'module_id': instance.moduleId,
      'extrinsic_index': instance.txNumber,
      'slash_kton': instance.slashKton,
      'params': instance.params,
    };
