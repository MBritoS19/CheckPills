import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart'; // <- 1. IMPORTAÇÃO ADICIONADA
import 'package:provider/provider.dart';

class ProfileManagementScreen extends StatelessWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final allUsers = userProvider.allUsers;
    final activeUser = userProvider.activeUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Perfis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddOrEditProfileDialog(context, userProvider),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          final user = allUsers[index];
          final bool isActive = user.id == activeUser?.id;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: Icon(
                isActive ? Icons.check_circle : Icons.person_outline,
                color: isActive ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(
                user.name,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                userProvider.selectUser(user);
                Navigator.of(context).pop();
              },
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddOrEditProfileDialog(context, userProvider,
                        userToEdit: user);
                  } else if (value == 'delete') {
                    _showConfirmDeleteDialog(context, userProvider, user);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Renomear'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Excluir'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddOrEditProfileDialog(
      BuildContext context, UserProvider provider,
      {User? userToEdit}) {
    final bool isEditing = userToEdit != null;
    final controller = TextEditingController(text: isEditing ? userToEdit.name : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Renomear Perfil' : 'Adicionar Novo Perfil'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome do perfil'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Salvar'),
            onPressed: () {
              final name = controller.text;
              if (name.isNotEmpty) {
                if (isEditing) {
                  provider.updateUser(
                      UsersCompanion(id: Value(userToEdit.id), name: Value(name)));
                } else {
                  provider.addUser(name);
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  // 2. MÉTODO DE CONFIRMAÇÃO MODIFICADO
  void _showConfirmDeleteDialog(
      BuildContext context, UserProvider provider, User userToDelete) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Tem certeza que deseja excluir o perfil "${userToDelete.name}"? Todos os medicamentos e dados associados a ele serão perdidos permanentemente.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Excluir'),
            onPressed: () async {
              // Fecha o dialog de confirmação antes de pedir a senha
              Navigator.of(dialogContext).pop(); 
              // Tenta autenticar antes de excluir
              await _authenticateAndDelete(context, provider, userToDelete);
            },
          ),
        ],
      ),
    );
  }

  // 3. NOVO MÉTODO PARA AUTENTICAÇÃO E EXCLUSÃO
  Future<void> _authenticateAndDelete(
      BuildContext context, UserProvider provider, User userToDelete) async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason:
            'Por favor, autentique-se para excluir o perfil "${userToDelete.name}".',
        options: const AuthenticationOptions(
          stickyAuth: true, // Mantém o pedido de autenticação na tela
        ),
      );

      if (didAuthenticate && context.mounted) {
        // Se autenticou com sucesso, exclui o usuário
        provider.deleteUser(userToDelete.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil "${userToDelete.name}" excluído com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        // Se o usuário cancelou
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exclusão cancelada.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on PlatformException catch (e) {
      // Se ocorreu um erro (ex: sem biometria cadastrada)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de autenticação: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}