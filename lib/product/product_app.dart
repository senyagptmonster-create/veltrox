import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'veltrox_store.dart';
import 'screens.dart';

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VeltroxStore()),
      ],
      child: MaterialApp(
        title: 'Veltrox Timer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: const VeltroxHome(),
      ),
    );
  }
}
