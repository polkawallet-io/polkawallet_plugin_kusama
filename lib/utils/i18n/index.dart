import 'package:polkawallet_plugin_chainx/utils/i18n/en/common.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/en/gov.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/en/staking.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/zh/common.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/zh/gov.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/zh/staking.dart';

const Map<String, Map<String, Map<String, String>>> i18n_full_dic_chainx = {
  'en': {
    'common': enCommon,
    'staking': enStaking,
    'gov': enGov,
  },
  'zh': {
    'common': zhCommon,
    'staking': zhStaking,
    'gov': zhGov,
  }
};
