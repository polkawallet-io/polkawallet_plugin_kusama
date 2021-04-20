import 'package:polkawallet_plugin_chainx/store/staking/types/nominationData.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';

class UnfreezeArgData {
  ValidatorData validator;
  List<BondedChunksData> unbondedChunks;

  UnfreezeArgData(ValidatorData _validator, List<BondedChunksData> _unbondedChunks) {
    this.validator = _validator;
    this.unbondedChunks = _unbondedChunks;
  }
}
