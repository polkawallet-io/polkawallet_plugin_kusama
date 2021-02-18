import 'package:flutter/material.dart';

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const node_list_chainx = [
  {
    'name': 'ChainX (Overseas Node)',
    'ss58': 44,
    'endpoint': 'wss://mainnet.chainx.org/ws',
  },
  {
    'name': 'ChainX (Elena Node)',
    'ss58': 44,
    'endpoint': 'wss://chainx.elara.patract.io',
  },
  {
    'name': 'ChainX (Staging)',
    'ss58': 44,
    'endpoint': 'wss://chainx.gregorst.org',
  },
];
// const home_nav_items = ['staking', 'governance'];
const home_nav_items = [];

const MaterialColor chainx_yellow = const MaterialColor(
  0xFFF6C94A,
  const <int, Color>{
    50: const Color(0xFFFBE8B1),
    100: const Color(0xFFFAE29E),
    200: const Color(0xFFF9DC8A),
    300: const Color(0xFFF9D677),
    400: const Color(0xFFF8D063),
    500: const Color(0xFFF6C94A),
    600: const Color(0xFFF6C43C),
    700: const Color(0xFFF5BE29),
    800: const Color(0xFFF4B915),
    900: const Color(0xFFEAAE0B),
  },
);

const String network_name_chainx = 'chainx';
