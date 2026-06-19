import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/auth_cubit.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Conta',
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (value) {
        if (value == 'logout') context.read<AuthCubit>().logout();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(context.read<AuthCubit>().state.session?.email ?? ''),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout),
            title: Text('Sair'),
          ),
        ),
      ],
    );
  }
}
