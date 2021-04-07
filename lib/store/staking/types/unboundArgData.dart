import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';

class UnboundArgData {
  ValidatorData validator;
  String recovable = '';

  UnboundArgData(ValidatorData _validator, String _recovable) {
    this.validator = _validator;
    this.recovable = _recovable;
  }
}
