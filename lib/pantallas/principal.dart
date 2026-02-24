// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import '../features/shell/main_shell.dart';

/// PrincipalPage delega toda la UI al nuevo MainShell.
/// Se mantiene el nombre para compatibilidad con la navegación del login.
class PrincipalPage extends StatelessWidget {
  const PrincipalPage({super.key});

  @override
  Widget build(BuildContext context) => const MainShell();
}
