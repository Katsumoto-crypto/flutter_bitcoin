import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_wallet/services/wallet_service.dart';
import 'package:flutter_wallet/wallet_pages/ca_wallet_page.dart';
import 'package:flutter_wallet/wallet_pages/create_shared_wallet.dart';
import 'package:flutter_wallet/wallet_pages/import_shared_wallet.dart';
import 'package:flutter_wallet/utilities/pin_setup_page.dart';
import 'package:flutter_wallet/utilities/pin_verification_page.dart';
import 'package:flutter_wallet/wallet_pages/shared_wallet_info.dart';
import 'package:flutter_wallet/wallet_pages/shared_wallet_page.dart';
import 'package:flutter_wallet/utilities/theme_provider.dart';
import 'package:flutter_wallet/hive/wallet_data.dart';
import 'package:flutter_wallet/wallet_pages/wallet_page.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure all Flutter bindings are initialized before running Hive
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // Initialize Hive

  // Register the generated Hive adapter for WalletData
  Hive.registerAdapter(WalletDataAdapter());

  // Retrieve or generate encryption key
  // final encryptionKey = await _getEncryptionKey();

  // Open the encrypted boxes
  await Hive.openBox(
    'walletBox',
    // encryptionCipher: HiveAesCipher(encryptionKey),
  );

  await Hive.openBox(
    'wallet_descriptors',
    // encryptionCipher: HiveAesCipher(encryptionKey),
  );

  runApp(const MyApp());
}

// TODO: Resolve stackoverflow problem with Data Encryption

// // FlutterSecureStorage for encryption key management
// final secureStorage = FlutterSecureStorage();

// Future<List<int>> _getEncryptionKey() async {
//   String? encodedKey = await secureStorage.read(key: 'encryptionKey');

//   if (encodedKey != null) {
//     return base64Url.decode(encodedKey);
//   } else {
//     var key = Hive.generateSecureKey();
//     await secureStorage.write(
//         key: 'encryptionKey', value: base64UrlEncode(key));
//     return key;
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(darkTheme)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Wallet',
            theme: themeProvider.themeData,
            initialRoute: _determineInitialRoute(),
            routes: {
              '/wallet_page': (context) => const WalletPage(),
              '/ca_wallet_page': (context) => const CAWalletPage(),
              '/pin_setup_page': (context) => const PinSetupPage(),
              '/pin_verification_page': (context) =>
                  const PinVerificationPage(),
              '/shared_wallet': (context) => const SharedWalletPage(),
              '/create_shared': (context) => const CreateSharedWallet(),
              '/import_shared': (context) => const ImportSharedWallet(),
              '/shared_wallet_info': (context) => const SharedWalletInfo(),
            },
          );
        },
      ),
    );
  }

  String _determineInitialRoute() {
    var walletBox = Hive.box('walletBox');

    if (!walletBox.containsKey('userPin')) {
      // If the user hasn't set a PIN yet
      return '/pin_setup_page';
    } else if (walletBox.containsKey('walletMnemonic')) {
      // If the wallet mnemonic exists, navigate to PIN verification
      return '/pin_verification_page';
    } else {
      // If no wallet mnemonic, navigate to wallet creation
      return '/ca_wallet_page';
    }
  }
}
