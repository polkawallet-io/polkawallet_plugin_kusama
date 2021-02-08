import 'package:flutter/material.dart';

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const node_list_chainx = [
  {
    'name': 'Kusama (Polkadot Canary, hosted by PatractLabs)',
    'ss58': 2,
    'endpoint': 'wss://kusama.elara.patract.io',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by Polkawallet)',
    'ss58': 2,
    'endpoint': 'wss://kusama-1.polkawallet.io:9944/',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by Polkawallet Asia)',
    'ss58': 2,
    'endpoint': 'wss://kusama-2.polkawallet.io/',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by Parity)',
    'ss58': 2,
    'endpoint': 'wss://kusama-rpc.polkadot.io/',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by onfinality)',
    'ss58': 2,
    'endpoint': 'wss://kusama.api.onfinality.io/public-ws',
  },
];
const node_list_polkadot = [
  {
    'name': 'Polkadot (Live, hosted by PatractLabs)',
    'ss58': 0,
    'endpoint': 'wss://polkadot.elara.patract.io',
  },
  {
    'name': 'Polkadot (Live, hosted by Polkawallet CN)',
    'ss58': 0,
    'endpoint': 'wss://polkadot-1.polkawallet.io:9944',
  },
  {
    'name': 'Polkadot (Live, hosted by Polkawallet EU)',
    'ss58': 0,
    'endpoint': 'wss://polkadot-2.polkawallet.io',
  },
  {
    'name': 'Polkadot (Live, hosted by Parity)',
    'ss58': 0,
    'endpoint': 'wss://rpc.polkadot.io',
  },
  {
    'name': 'Polkadot (Live, hosted by onfinality)',
    'ss58': 0,
    'endpoint': 'wss://polkadot.api.onfinality.io/public-ws',
  },
];

const home_nav_items = ['staking', 'governance'];

const MaterialColor chainx_black = const MaterialColor(
  0xFF222222,
  const <int, Color>{
    50: const Color(0xFF555555),
    100: const Color(0xFF444444),
    200: const Color(0xFF444444),
    300: const Color(0xFF333333),
    400: const Color(0xFF333333),
    500: const Color(0xFF222222),
    600: const Color(0xFF111111),
    700: const Color(0xFF111111),
    800: const Color(0xFF000000),
    900: const Color(0xFF000000),
  },
);

const String network_name_chainx = 'chainx';
const String network_name_polkadot = 'polkadot';
